RSpec.describe ActsAsMentionable::Mentionable do
  let(:mentionable) { MentionableModel.create! }
  let(:mentioners) { Array.new(2).map { MentionerModel.create! } }

  let :mentions do
    ActsAsMentionable::Mention.create! mentioner: MentionerModel.create!, mentionable: MentionableModel.create!

    mentioners.map do |mentioner|
      ActsAsMentionable::Mention.create! mentioner: mentioner, mentionable: mentionable
    end
  end

  describe '#mentions' do
    subject(:mentionable_mentions) { mentionable.mentions }

    it { is_expected.to eq mentions }
  end

  describe '#mentionable?' do
    subject(:mentionable) { MentionableModel.new.mentionable? }

    it { is_expected.to be_truthy }
  end

  describe '#mentioners' do
    subject(:mentionable_mentioners) { mentionable.mentioners }

    before { mentions }

    it { is_expected.to eq mentioners }
  end
end
