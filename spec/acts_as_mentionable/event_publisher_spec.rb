RSpec.describe ActsAsMentionable::EventPublisher do
  subject(:instance) { described_class.new mentioner, changes }

  let(:mentioner) { ActsAsMentionable::DummyMentioner.new }
  let(:changes) { { added: added, removed: removed } }
  let(:added) { [] }
  let(:removed) { [] }

  describe '#call' do
    subject(:publish_events_lambda) { -> { instance.call } }

    let(:added_mentionable) { ActsAsMentionable::DummyMentionee.new }
    let(:removed_community_mentionable) { ActsAsMentionable::DummyMentionee.new }

    let(:added) { [added_mentionable] }
    let(:removed) { [removed_community_mentionable] }

    before do
      allow(added_mentionable).to receive(:on_mentionable_added)
      allow(removed_community_mentionable).to receive(:on_mentionable_removed)
      allow(removed_community_mentionable).to receive(:respond_to?).with(:on_mentionable_removed) { false }
    end

    it { is_expected.to broadcast :mentionable_added, added_mentionable, mentioner }
    it { is_expected.to broadcast :mentionable_mention_added, added_mentionable, mentioner }

    it { is_expected.to broadcast :mentionable_removed, removed_community_mentionable, mentioner }
    it { is_expected.to broadcast :community_mention_removed, removed_community_mentionable, mentioner }

    it 'invokes corresponding method on mentionable if method defined', :aggregate_failures do
      publish_events_lambda.call

      expect(added_mentionable).to have_received(:on_mentionable_added).with(mentioner)
      expect(removed_community_mentionable).not_to have_received(:on_mentionable_removed)
    end
  end
end
