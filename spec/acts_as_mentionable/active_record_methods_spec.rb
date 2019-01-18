RSpec.describe ActsAsMentionable::ActiveRecordMethods do
  subject :active_record_class do
    Class.new { include ActsAsMentionable::ActiveRecordMethods }
  end

  it { is_expected.not_to include ActsAsMentionable::Mentionable }
  it { is_expected.not_to include ActsAsMentionable::Mentioner }

  it { is_expected.to respond_to :acts_as_mentionable }
  it { is_expected.to respond_to :acts_as_mentioner }

  it { is_expected.not_to respond_to :mentionable_field }
  it { is_expected.not_to respond_to :mention_field }
  it { is_expected.not_to respond_to :mention_parsed_field }

  describe '.acts_as_mentionable' do
    subject { active_record_class.acts_as_mentionable :username }

    before { allow(active_record_class).to receive(:has_many) }

    it { is_expected.to respond_to :mentionable_field }
    it { is_expected.to include ActsAsMentionable::Mentionable }
    it { is_expected.not_to include ActsAsMentionable::Mentioner }
  end

  describe '.acts_as_mentioner' do
    subject { active_record_class.acts_as_mentioner :body }

    before { allow(active_record_class).to receive(:has_many) }

    it { is_expected.to respond_to :mention_field }
    it { is_expected.to respond_to :mention_parsed_field }
    it { is_expected.to include ActsAsMentionable::Mentioner }
    it { is_expected.not_to include ActsAsMentionable::Mentionable }
  end

  describe 'active_record instance' do
    subject { active_record_class.new }

    its(:mentionable?) { is_expected.to be_falsey }
    its(:mentioner?) { is_expected.to be_falsey }
  end
end
