RSpec.describe ActsAsMentionable::Mentioner do
  let(:instance) { MentionerModel.new }
  let(:mentioner) { MentionerModel.create! }
  let(:mentionables) { Array.new(2).map { MentionableModel.create! } }

  let :mentions do
    ActsAsMentionable::Mention.create! mentioner: MentionerModel.create!, mentionable: MentionableModel.create!

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

  describe '#mentions' do
    subject(:mentioner_mentions) { mentioner.mentions }

    it { is_expected.to eq mentions }
  end

  describe '#mentioner?' do
    subject(:mentioner) { MentionerModel.new.mentioner? }

    it { is_expected.to be_truthy }
  end

  describe '#mentionables' do
    subject(:mentioner_mentionables) { mentioner.mentionables }

    before { mentions }

    it { is_expected.to eq mentionables }
  end
end
