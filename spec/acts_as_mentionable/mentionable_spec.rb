RSpec.describe ActsAsMentionable::Mentionable do
  let(:mentionable) { Mentionable.create! }
  let(:mentioners) { 2.times.map { Mentioner.create! } }

  let :mentions do
    ActsAsMentionable::Mention.create! mentioner: Mentioner.create!, mentionable: Mentionable.create!

    mentioners.map do |mentioner|
      ActsAsMentionable::Mention.create! mentioner: mentioner, mentionable: mentionable
    end
  end

  describe '#mentions' do
    subject(:mentionable_mentions) { mentionable.mentions }

    it { is_expected.to eq mentions }
  end

  describe '#mentionable?' do
    subject(:mentionable) { Mentionable.new.mentionable? }

    it { is_expected.to be_truthy }
  end

  describe '#mentioners' do
    subject(:mentionable_mentioners) { mentionable.mentioners }

    before { mentions }

    it { is_expected.to eq mentioners }
  end
end
