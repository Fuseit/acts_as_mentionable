RSpec.describe ActsAsMentionable::Mention do
  let(:mentioner) { Mentioner.create! }
  let(:mentionable) { Mentionable.create! }
  let(:dummy) { Dummy.create! }

  let(:mention) { described_class.create! mentioner: mentioner, mentionable: mentionable }

  shared_context 'with mentions', :with_mentions do
    before do
      mention
      described_class.create! mentioner: Mentioner.create!, mentionable: Mentionable.create!
    end
  end

  describe '.by_mentioners', :with_mentions do
    subject(:mentioners) { described_class.by_mentioners(provided_mentioner).to_a }

    let(:provided_mentioner) { mentioner }

    it { is_expected.to eq [mention] }

    context 'when mentions does not exist' do
      let(:provided_mentioner) { dummy }

      it { is_expected.to be_empty }
    end
  end

  describe '.by_mentionables', :with_mentions do
    subject(:mentionables) { described_class.by_mentionables(provided_mentionable).to_a }


    let(:provided_mentionable) { mentionable }

    it { is_expected.to eq [mention] }

    context 'when mentions does not exist' do
      let(:provided_mentionable) { dummy }

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

    let(:new_mentionable) { Mentionable.create! }

    it { is_expected.to change { described_class.count }.by(1) }
    it { is_expected.to change { described_class.by_mentionables(new_mentionable).exists? }.from(false).to(true) }
  end

  describe '#mentioner' do
    subject(:mention_mentioner) { mention.mentioner }

    it { is_expected.to eq mentioner }
  end

  describe '#mentionable' do
    subject(:mention_mentionable) { mention.mentionable }

    it { is_expected.to eq mentionable }
  end

  describe 'validation' do
    subject(:mention) { described_class.new mentioner: provided_mentioner, mentionable: provided_mentionable }

    let(:provided_mentioner) { mentioner }
    let(:provided_mentionable) { mentionable }
    let(:respond_to_mentioner) { true }
    let(:respond_to_mentionable) { true }

    before do
      allow(provided_mentioner).to receive(:respond_to?).with(:mentioner?) { respond_to_mentioner }
      allow(provided_mentionable).to receive(:respond_to?).with(:mentionable?) { respond_to_mentionable }
    end

    it { is_expected.to be_valid }

    context 'when mentioner does not respond to mentioner?' do
      let(:respond_to_mentioner) { false }

      it 'is invalid', :aggregate_failures do
        expect(mention).to be_invalid
        expect(mention.errors.messages).to eq mentioner: ['is invalid']
      end
    end

    context 'when mentioner is not a mentioner' do
      let(:provided_mentioner) { dummy }

      it 'is invalid', :aggregate_failures do
        expect(mention).to be_invalid
        expect(mention.errors.messages).to eq mentioner: ['is invalid']
      end
    end

    context 'when mentionable does not respond to mentionable?' do
      let(:respond_to_mentionable) { false }

      it 'is invalid', :aggregate_failures do
        expect(mention).to be_invalid
        expect(mention.errors.messages).to eq mentionable: ['is invalid']
      end
    end

    context 'when mentionable is not a mentionable' do
      let(:provided_mentionable) { dummy }

      it 'is invalid', :aggregate_failures do
        expect(mention).to be_invalid
        expect(mention.errors.messages).to eq mentionable: ['is invalid']
      end
    end
  end
end
