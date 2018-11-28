RSpec.describe ActsAsMentionable::Mentioner do
  let(:instance) { Mentioner.new }
  let(:mentioner) { Mentioner.create! }
  let(:mentionables) { 2.times.map { Mentionable.create! } }

  let :mentions do
    ActsAsMentionable::Mention.create! mentioner: Mentioner.create!, mentionable: Mentionable.create!

    mentionables.map do |mentionable|
      ActsAsMentionable::Mention.create! mentioner: mentioner, mentionable: mentionable
    end
  end

  let(:changed) { false }
  let(:changes) { double }

  let :mentionables_manipulator do
    instance_spy 'ActsAsMentionable::MentionablesManipulator',
      changed?: changed,
      changes: changes
  end

  before do
    allow(ActsAsMentionable::MentionablesManipulator).to receive(:new).with([]) { mentionables_manipulator }
  end

  describe '#mentions' do
    subject(:mentioner_mentions) { mentioner.mentions }

    it { is_expected.to eq mentions }
  end

  describe '#mentioner?' do
    subject(:mentioner) { Mentioner.new.mentioner? }

    it { is_expected.to be_truthy }
  end

  describe '#mentionables' do
    subject(:mentioner_mentionables) { mentioner.mentionables }

    before { mentions }

    it { is_expected.to eq mentionables }
  end

  shared_examples_for 'invokes method on MentionablesManipulator and saves' do |method_name|
    let(:mentionables) { [double, double] }
    let(:save) { false }
    let(:options) { save ? { save: true } : {} }

    before { allow(instance).to receive(:save_mentions) }

    it "invokes #{method_name} on MentionablesManipulator", :aggregate_failures do
      invoke_mentioner_method

      expect(mentionables_manipulator).to have_received(method_name).with(*mentionables)
      expect(instance).not_to have_received(:save_mentions)
    end

    context 'when save option is specified' do
      let(:save) { true }

      it "invokes #{method_name} on MentionablesManipulator and saves changes", :aggregate_failures do
        invoke_mentioner_method

        expect(mentionables_manipulator).to have_received(method_name).with(*mentionables).ordered
        expect(instance).to have_received(:save_mentions).ordered
      end
    end
  end

  describe '#mention' do
    subject(:invoke_mentioner_method) { instance.mention(*mentionables, **options) }

    it_behaves_like 'invokes method on MentionablesManipulator and saves', :add
  end

  describe '#unmention' do
    subject(:invoke_mentioner_method) { instance.unmention(*mentionables, **options) }

    it_behaves_like 'invokes method on MentionablesManipulator and saves', :remove
  end

  describe '#replace_mentionables' do
    subject(:invoke_mentioner_method) { instance.replace_mentionables(*mentionables, **options) }

    it_behaves_like 'invokes method on MentionablesManipulator and saves', :replace
  end

  describe '#save_mentions' do
    subject(:save_mentions) { instance.save_mentions }

    let(:mentions_updater) { instance_spy 'ActsAsMentionable::MentionsUpdater' }

    before do
      allow(ActsAsMentionable::MentionsUpdater).to receive(:new) { mentions_updater }
      allow(mentions_updater).to receive(:call) { |&block| block.call }
    end

    it 'does not save changes', :aggregate_failures do
      save_mentions

      expect(ActsAsMentionable::MentionsUpdater).not_to have_received(:new)
      expect(mentionables_manipulator).not_to have_received(:fix_changes!)
    end

    context 'when changed' do
      let(:changed) { true }

      it 'saves changes', :aggregate_failures do
        save_mentions

        expect(ActsAsMentionable::MentionsUpdater).to have_received(:new).with(instance, changes).ordered
        expect(mentions_updater).to have_received(:call).ordered
        expect(mentionables_manipulator).to have_received(:fix_changes!).ordered
        expect(mentionables_manipulator).not_to have_received(:replace)
      end

      context 'and transaction is rolled back' do
        let(:current) { double }

        before do
          allow(ActsAsMentionable::TransactionCallbacks).to receive(:on_rolled_back).and_yield
          allow(mentionables_manipulator).to receive(:current) { current }
        end

        it 'restores mentionables manipulator state', :aggregate_failures do
          save_mentions

          expect(ActsAsMentionable::MentionablesManipulator).to have_received(:new).twice.ordered
          expect(mentionables_manipulator).to have_received(:replace).with(current).ordered
        end
      end
    end
  end
end
