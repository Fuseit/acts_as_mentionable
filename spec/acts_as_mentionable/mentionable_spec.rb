RSpec.describe ActsAsMentionable::Mentionable do
  let(:mentionable) { MentionableModel.create! }
  let(:mentions) { [ActsAsMentionable::Mention.create!(mentionable: mentionable)] }

  describe '#mentions' do
    subject(:mentionable_mentions) { mentionable.mentions }

    it { is_expected.to eq mentions }
  end
end
