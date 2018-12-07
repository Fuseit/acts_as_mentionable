RSpec.describe ActsAsMentionable::RetrievePolymorphic do
  describe '#call' do
    subject(:call) { described_class.new(relation, association_name).call }

    let(:relation) { ActsAsMentionable::Mention.where(mentioner: mentioner) }
    let(:association_name) { :mentionable }
    let(:mentioner) { MentionerModel.create! }
    let(:foo) { MentionableModel.create! }
    let(:bar) { PlainModel.create! }

    before do
      [foo, bar].each do |model|
        allow(model).to receive(:mentionable?).and_return(true)
        ActsAsMentionable::Mention.create! mentioner: mentioner, mentionable: model
      end

      ActsAsMentionable::Mention.create! \
        mentioner: MentionerModel.create!,
        mentionable: MentionableModel.create!
    end

    it { is_expected.to match_array [foo, bar] }
  end
end
