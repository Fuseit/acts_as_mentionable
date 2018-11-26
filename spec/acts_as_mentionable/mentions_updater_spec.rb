RSpec.describe ActsAsMentionable::MentionsUpdater do
  describe '#call' do
    subject(:call) { described_class.new(mentioner, changes).call }

    let(:mentioner) { ActsAsMentionable::DummyMentioner.new }
    let(:changes) { { added: added, removed: removed } }
    let(:added) { [double] }
    let(:removed) { [double] }
    let(:event_publisher) { instance_spy 'ActsAsMentionable::EventPublisher', call: nil }

    before do
      allow(ActsAsMentionable::Mention).to receive(:remove_mentionables_for_mentioner)
      allow(ActsAsMentionable::Mention).to receive(:add_mentionables_for_mentioner)
      allow(ActsAsMentionable::TransactionCallbacks).to receive(:on_committed).and_yield
      allow(ActsAsMentionable::EventPublisher).to receive(:new) { event_publisher }
    end

    it 'invokes logic in order', :aggregate_failures do
      call

      expect(ActsAsMentionable::Mention).to \
        have_received(:remove_mentionables_for_mentioner).with(mentioner, removed).ordered

      expect(ActsAsMentionable::Mention).to \
        have_received(:add_mentionables_for_mentioner).with(mentioner, added).ordered

      expect(ActsAsMentionable::TransactionCallbacks).to have_received(:on_committed).ordered
      expect(ActsAsMentionable::EventPublisher).to have_received(:new).with(mentioner, changes).ordered
      expect(event_publisher).to have_received(:call).ordered
    end

    context 'when nothing added' do
      let(:added) { [] }

      it 'does not invoke Mention#add_mentionables_for_mentioner' do
        call
        expect(ActsAsMentionable::Mention).not_to have_received(:add_mentionables_for_mentioner)
      end
    end

    context 'when nothing removed' do
      let(:removed) { [] }

      it 'does not invoke Mention#remove_mentionables_for_mentioner' do
        call
        expect(ActsAsMentionable::Mention).not_to have_received(:remove_mentionables_for_mentioner)
      end
    end
  end
end
