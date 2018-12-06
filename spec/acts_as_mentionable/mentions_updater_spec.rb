RSpec.describe ActsAsMentionable::MentionsUpdater do
  describe '#call' do
    subject(:update_mentions) { -> { described_class.new(mentioner, changes).call(&block) } }

    let(:mentioner) { MentionerModel.create! }
    let(:changes) { { added: added, removed: removed } }
    let(:block) { nil }
    let(:added) { [added_mentionable] }
    let(:removed) { [removed_mentionable] }
    let(:added_mentionable) { MentionableModel.create! }
    let(:removed_mentionable) { MentionableModel.create! }
    let(:mentionable_exists) { ActsAsMentionable::Mention.by_mentionables(mentionable).exists? }

    before do
      ActsAsMentionable::Mention.create! mentioner: mentioner, mentionable: removed_mentionable

      allow(ActsAsMentionable::Mention).to receive(:remove_mentionables_for_mentioner).and_call_original
      allow(ActsAsMentionable::Mention).to receive(:add_mentionables_for_mentioner).and_call_original
      allow(ActsAsMentionable::TransactionCallbacks).to receive(:on_committed).and_yield
    end

    def mentionable_exists? mentionable
      ActsAsMentionable::Mention.by_mentionables(mentionable).exists?
    end

    it { is_expected.to change { mentionable_exists? removed_mentionable }.from(true).to(false) }
    it { is_expected.to change { mentionable_exists? added_mentionable }.from(false).to(true) }

    context 'when nothing added' do
      let(:added) { [] }

      it 'does not invoke Mention#add_mentionables_for_mentioner', :aggregate_failures do
        update_mentions.call

        expect(ActsAsMentionable::Mention).not_to have_received :add_mentionables_for_mentioner
        expect(ActsAsMentionable::Mention).to have_received :remove_mentionables_for_mentioner
      end
    end

    context 'when nothing removed' do
      let(:removed) { [] }

      it 'does not invoke Mention#remove_mentionables_for_mentioner', :aggregate_failures do
        update_mentions.call

        expect(ActsAsMentionable::Mention).not_to have_received :remove_mentionables_for_mentioner
        expect(ActsAsMentionable::Mention).to have_received :add_mentionables_for_mentioner
      end
    end

    context 'when block provided', skip_transactions: true do
      let(:block) { -> { ActsAsMentionable::Mention.connection.current_transaction } }
      let(:added) { [] }
      let(:removed) { [] }

      it { expect(update_mentions.call).to be_open }
    end
  end
end
