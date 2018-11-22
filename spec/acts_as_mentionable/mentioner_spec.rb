RSpec.describe ActsAsMentionable::Mentioner do
  let(:instance) { model_class.new }

  let :model_class do
    Class.new ActiveRecord::Base do
      self.table_name = 'companies'

      include ActsAsMentionable::Mentioner
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
    subject(:mentions) { instance.mentions }

    let(:instance) { model_class.create! }

    let(:mentionables) { create_list :user, 2 }

    let :expected_mentions do
      mentionables.map do |mentionable|
        ActsAsMentionable::Mention.create! mentionable: mentionable, mentioner: instance
      end
    end

    before do
      stub_const 'ActsAsMentionable::FooModel', model_class

      ActsAsMentionable::Mention.create! mentionable: mentionables.first, mentioner: model_class.create!
    end

    it { is_expected.to eq expected_mentions }
  end

  describe '#mentioner?' do
    subject(:mentioner) { instance.mentioner? }

    it { is_expected.to be_truthy }
  end

  describe '#mentionables' do
    subject(:mentioners) { instance.mentionables }

    let(:expected_mentionables) { double }

    let :retrieve_polymorphic_instance do
      instance_double 'ActsAsMentionable::RetrievePolymorphic', call: expected_mentionables
    end

    before do
      allow(ActsAsMentionable::RetrievePolymorphic).to receive(:new) { retrieve_polymorphic_instance }
    end

    it 'invokes RetrievePolymorphic and returns its result', :aggregate_failures do
      expect(mentioners).to eq expected_mentionables

      expect(ActsAsMentionable::RetrievePolymorphic).to \
        have_received(:new).with(instance.mentions, :mentionable)
    end
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
      allow(ActsAsMentionable::TransactionCallbacks).to receive(:on_committed).and_yield
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
        expect(ActsAsMentionable::TransactionCallbacks).to have_received(:on_committed).ordered
        expect(mentionables_manipulator).to have_received(:fix_changes!).ordered
      end
    end
  end
end
