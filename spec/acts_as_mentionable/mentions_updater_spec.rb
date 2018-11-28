RSpec.describe ActsAsMentionable::MentionsUpdater do
  describe '#call' do
    subject(:update_mentions) { -> { described_class.new(mentioner, changes).call(&block) } }

    let(:mentioner) { Mentioner.create! }
    let(:changes) { { added: added, removed: removed } }
    let(:block) { nil }
    let(:added) { [added_mentionable] }
    let(:removed) { [removed_mentionable] }
    let(:added_mentionable) { Mentionable.create! }
    let(:removed_mentionable) { Mentionable.create! }
    let(:event_publisher) { instance_spy 'ActsAsMentionable::EventPublisher', call: nil }

    before do
      ActsAsMentionable::Mention.create! mentioner: mentioner, mentionable: removed_mentionable

      allow(ActsAsMentionable::Mention).to receive(:remove_mentionables_for_mentioner).and_call_original
      allow(ActsAsMentionable::Mention).to receive(:add_mentionables_for_mentioner).and_call_original
      allow(ActsAsMentionable::TransactionCallbacks).to receive(:on_committed).and_yield
      allow(ActsAsMentionable::EventPublisher).to receive(:new) { event_publisher }
    end

    it 'deletes mention' do
      is_expected.to change { ActsAsMentionable::Mention.by_mentionables(removed_mentionable).exists? }
        .from(true)
        .to(false)
    end

    it 'creates mention' do
      is_expected.to change { ActsAsMentionable::Mention.by_mentionables(added_mentionable).exists? }
        .from(false)
        .to(true)
    end

    it 'invokes logic in order', :aggregate_failures do
      update_mentions.call

      expect(ActsAsMentionable::TransactionCallbacks).to have_received(:on_committed).ordered
      expect(ActsAsMentionable::EventPublisher).to have_received(:new).with(mentioner, changes).ordered
      expect(event_publisher).to have_received(:call).ordered
    end

    context 'when nothing added' do
      let(:added) { [] }

      it 'does not invoke Mention#add_mentionables_for_mentioner' do
        update_mentions.call

        expect(ActsAsMentionable::Mention).not_to have_received :add_mentionables_for_mentioner
        expect(ActsAsMentionable::Mention).to have_received :remove_mentionables_for_mentioner
      end
    end

    context 'when nothing removed' do
      let(:removed) { [] }

      it 'does not invoke Mention#remove_mentionables_for_mentioner' do
        update_mentions.call

        expect(ActsAsMentionable::Mention).not_to have_received :remove_mentionables_for_mentioner
        expect(ActsAsMentionable::Mention).to have_received :add_mentionables_for_mentioner
      end
    end

    context 'when block provided', skip_transactions: true do
      let(:block) { -> { ActsAsMentionable::Mention.connection.current_transaction.open? } }
      let(:added) { [] }
      let(:removed) { [] }

      it { expect(update_mentions.call).to be_truthy }
    end
  end
end
