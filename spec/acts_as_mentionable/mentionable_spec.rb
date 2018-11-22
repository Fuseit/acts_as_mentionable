RSpec.describe ActsAsMentionable::Mentionable do
  let(:instance) { model_class.new }

  let :model_class do
    Class.new ActiveRecord::Base do
      self.table_name = 'companies'

      include ActsAsMentionable::Mentionable
    end
  end

  describe '#mentions' do
    subject(:mentions) { instance.mentions }

    let(:instance) { model_class.create! }

    let(:mentioners) { create_list :comment, 2 }

    let :expected_mentions do
      mentioners.map do |mentioner|
        ActsAsMentionable::Mention.create! mentioner: mentioner, mentionable: instance
      end
    end

    before do
      stub_const 'ActsAsMentionable::FooModel', model_class

      ActsAsMentionable::Mention.create! mentioner: mentioners.first, mentionable: model_class.create!
    end

    it { is_expected.to eq expected_mentions }
  end

  describe '#mentionable?' do
    subject(:mentionable) { instance.mentionable? }

    it { is_expected.to be_truthy }
  end

  describe '#mentioners' do
    subject(:mentioners) { instance.mentioners }

    let(:expected_mentioners) { double }

    let :retrieve_polymorphic_instance do
      instance_double 'ActsAsMentionable::RetrievePolymorphic', call: expected_mentioners
    end

    before do
      allow(ActsAsMentionable::RetrievePolymorphic).to receive(:new) { retrieve_polymorphic_instance }
    end

    it 'invokes RetrievePolymorphic and returns its result', :aggregate_failures do
      expect(mentioners).to eq expected_mentioners

      expect(ActsAsMentionable::RetrievePolymorphic).to \
        have_received(:new).with(instance.mentions, :mentioner)
    end
  end
end
