RSpec.describe ActsAsMentionable::Mention do
  let(:mentioner) { ActsAsMentionable::DummyMentioner.create  }
  let(:mentionable) { ActsAsMentionable::DummyMentionee.create  }

  let(:mention) { ActsAsMentionable::Mention.create mentioner: mentioner, mentionable: mentionable }

  shared_context 'with mentions', :with_mentions do
    before do
      mention
      ActsAsMentionable::Mention.create
    end
  end

  describe '.by_mentioners', :with_mentions do
    subject(:mentioners) { described_class.by_mentioners(mentioner).to_a }

    it { is_expected.to eq [mention] }

    context 'when mentions does not exist' do

      it { is_expected.to be_empty }
    end
  end

  describe '.by_mentionables', :with_mentions do
    subject(:mentionables) { described_class.by_mentionables(mentionable).to_a }

    it { is_expected.to eq [mention] }

    context 'when mentions does not exist' do

      it { is_expected.to be_empty }
    end
  end

  describe '.remove_mentionables_for_mentioner', :with_mentions do
    subject(:remove) { -> { described_class.remove_mentionables_for_mentioner mentioner, mentionable } }

    it { is_expected.to change { described_class.count }.by(-1) }
    it { is_expected.to change { described_class.exists? mention.id }.from(true).to(false) }
  end

  describe '.add_mentionables_for_mentioner', :with_mentions do
    subject(:add) { -> { described_class.add_mentionables_for_mentioner mentioner, new_mentionable } }

    let(:new_mentionable) { ActsAsMentionable::DummyMentionee.create }

    it { is_expected.to change { described_class.count }.by(1) }
    it { is_expected.to change { described_class.by_mentionables(new_mentionable).exists? }.from(false).to(true) }
  end

  describe '#mentioner' do
    subject(:mentioner) { mention.mentioner }

    it { is_expected.to eq mentioner }
  end

  describe '#mentionable' do
    subject(:mentionable) { mention.mentionable }

    it { is_expected.to eq mentionable }
  end

  describe 'validation' do
    subject(:mention) { ActsAsMentionable::Mention.new(mentioner: mentioner, mentionable: mentionable)}

    let(:respond_to_mentioner) { true }
    let(:respond_to_mentionable) { true }
    let(:is_mentioner) { true }
    let(:is_mentionable) { true }

    before do
      allow(mentioner).to receive(:respond_to?).with(:mentioner?) { respond_to_mentioner }
      allow(mentionable).to receive(:respond_to?).with(:mentionable?) { respond_to_mentionable }
      allow(mentioner).to receive(:mentioner?) { is_mentioner }
      allow(mentionable).to receive(:mentionable?) { is_mentionable }
    end

    it { is_expected.to be_valid }

    context 'when mentioner does not respond mentioner?' do
      let(:respond_to_mentioner) { false }

      it 'is invalid', :aggregate_failures do
        expect(mention).to be_invalid
        expect(mention.errors.messages).to eq mentioner: ['is invalid']
      end
    end

    context 'when mentioner is not a mentioner' do
      let(:is_mentioner) { false }

      it 'is invalid', :aggregate_failures do
        expect(mention).to be_invalid
        expect(mention.errors.messages).to eq mentioner: ['is invalid']
      end
    end

    context 'when mentionable does not respond mentionable?' do
      let(:respond_to_mentionable) { false }

      it 'is invalid', :aggregate_failures do
        expect(mention).to be_invalid
        expect(mention.errors.messages).to eq mentionable: ['is invalid']
      end
    end

    context 'when mentionable is not a mentionable' do
      let(:is_mentionable) { false }

      it 'is invalid', :aggregate_failures do
        expect(mention).to be_invalid
        expect(mention.errors.messages).to eq mentionable: ['is invalid']
      end
    end
  end
end
