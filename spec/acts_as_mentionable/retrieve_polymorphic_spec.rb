RSpec.describe ActsAsMentionable::RetrievePolymorphic do
  describe '#call' do
    subject(:call) { described_class.new(relation, association_name).call }

    let(:relation) { ActsAsMentionable::Mention.where(mentioner: mentioner) }
    let(:association_name) { :mentionable }

    let(:mentioner) { ActsAsMentionable::MentionerModel.create! }
    let(:foo) { ActsAsMentionable::FooModel.create! }
    let(:bar) { ActsAsMentionable::BarModel.create! }

    def dummy_model_class
      Class.new ActiveRecord::Base do
        self.table_name = 'companies'

        include ActsAsMentionable::Mentioner
        include ActsAsMentionable::Mentionable
      end
    end

    before do
      %w[MentionerModel FooModel BarModel].each do |model_class|
        stub_const "ActsAsMentionable::#{model_class}", dummy_model_class
      end

      [foo, bar].each do |model|
        ActsAsMentionable::Mention.create! mentioner: mentioner, mentionable: model
      end

      ActsAsMentionable::Mention.create! \
        mentioner: ActsAsMentionable::MentionerModel.create!,
        mentionable: ActsAsMentionable::FooModel.create!
    end

    it { is_expected.to match_array [foo, bar] }
  end
end
