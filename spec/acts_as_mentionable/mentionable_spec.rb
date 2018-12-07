RSpec.describe ActsAsMentionable::Mentionable do
  let(:mentionable) { MentionableModel.create! }
  let(:mentioner) { MentionerModel.create! }
  let(:mentions) { [ActsAsMentionable::Mention.create!(mentionable: mentionable, mentioner: mentioner)] }

  describe '#mentions' do
    subject(:mentionable_mentions) { mentionable.mentions }

    it { is_expected.to eq mentions }
  end
end
