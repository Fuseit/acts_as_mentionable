RSpec.describe ActsAsMentionable::MentionablesManipulator do
  subject(:instance) { described_class.new mentionables }

  let(:mentionables) { [first_mentionable, second_mentionable] }

  let(:first_mentionable) { instance_double 'Mentionable' }
  let(:second_mentionable) { instance_double 'Mentionable' }
  let(:third_mentionable) { instance_double 'Mentionable' }
  let(:fourth_mentionable) { instance_double 'Mentionable' }

  let(:changed) { false }
  let(:added) { [] }
  let(:removed) { [] }
  let(:previous) { mentionables }
  let(:current) { mentionables }

  let :changes do
    {
      changed: changed,
      added: added,
      removed: removed,
      previous: previous,
      current: current
    }
  end

  shared_examples_for 'reflects changes' do
    its(:changes) { is_expected.to eq changes }
    its(:changed?) { is_expected.to eq changes[:changed] }
    its(:added) { is_expected.to eq changes[:added] }
    its(:removed) { is_expected.to eq changes[:removed] }
    its(:previous) { is_expected.to eq changes[:previous] }
    its(:current) { is_expected.to eq changes[:current] }
  end

  it_behaves_like 'reflects changes'

  describe '#add' do
    subject(:add) { instance.add(*provided_mentionables) }

    context 'when single argument provided' do
      let(:provided_mentionables) { third_mentionable }

      it_behaves_like 'reflects changes' do
        let(:changed) { true }
        let(:added) { [third_mentionable] }
        let(:current) { super() + [third_mentionable] }
      end
    end

    context 'when several arguments provided' do
      let(:provided_mentionables) { [third_mentionable, fourth_mentionable] }

      it_behaves_like 'reflects changes' do
        let(:changed) { true }
        let(:added) { [third_mentionable, fourth_mentionable] }
        let(:current) { [first_mentionable, second_mentionable, third_mentionable, fourth_mentionable] }
      end
    end

    context 'when array provided' do
      let(:provided_mentionables) { [[third_mentionable, fourth_mentionable]] }

      it_behaves_like 'reflects changes' do
        let(:changed) { true }
        let(:added) { [third_mentionable, fourth_mentionable] }
        let(:current) { [first_mentionable, second_mentionable, third_mentionable, fourth_mentionable] }
      end
    end

    context 'when existing mentionable provided' do
      let(:provided_mentionables) { second_mentionable }

      it_behaves_like 'reflects changes'
    end
  end

  describe '#remove' do
    subject(:remove) { instance.remove(*provided_mentionables) }

    context 'when single argument provided' do
      let(:provided_mentionables) { second_mentionable }

      it_behaves_like 'reflects changes' do
        let(:changed) { true }
        let(:removed) { [second_mentionable] }
        let(:current) { [first_mentionable] }
      end
    end

    context 'when several arguments provided' do
      let(:provided_mentionables) { [first_mentionable, second_mentionable] }

      it_behaves_like 'reflects changes' do
        let(:changed) { true }
        let(:removed) { [first_mentionable, second_mentionable] }
        let(:current) { [] }
      end
    end

    context 'when array provided' do
      let(:provided_mentionables) { [[first_mentionable, second_mentionable]] }

      it_behaves_like 'reflects changes' do
        let(:changed) { true }
        let(:removed) { [first_mentionable, second_mentionable] }
        let(:current) { [] }
      end
    end

    context 'when non-existing mentionable provided' do
      let(:provided_mentionables) { third_mentionable }

      it_behaves_like 'reflects changes'
    end
  end

  describe '#replace' do
    subject(:replace) { instance.replace(*provided_mentionables) }

    context 'when single argument provided' do
      let(:provided_mentionables) { fourth_mentionable }

      it_behaves_like 'reflects changes' do
        let(:changed) { true }
        let(:added) { [fourth_mentionable] }
        let(:removed) { [first_mentionable, second_mentionable] }
        let(:current) { [fourth_mentionable] }
      end
    end

    context 'when several arguments provided' do
      let(:provided_mentionables) { [second_mentionable, fourth_mentionable] }

      it_behaves_like 'reflects changes' do
        let(:changed) { true }
        let(:added) { [fourth_mentionable] }
        let(:removed) { [first_mentionable] }
        let(:current) { [second_mentionable, fourth_mentionable] }
      end
    end

    context 'when array provided' do
      let(:provided_mentionables) { [[second_mentionable, fourth_mentionable]] }

      it_behaves_like 'reflects changes' do
        let(:changed) { true }
        let(:added) { [fourth_mentionable] }
        let(:removed) { [first_mentionable] }
        let(:current) { [second_mentionable, fourth_mentionable] }
      end
    end
  end

  describe '#fix_changes!' do
    subject(:fix_changes) { -> { instance.fix_changes! } }

    let(:changed) { true }
    let(:added) { [fourth_mentionable] }
    let(:removed) { [first_mentionable] }
    let(:current) { [second_mentionable, fourth_mentionable] }

    let(:new_changes) { changes.merge changed: false, added: [], removed: [], previous: current }

    before { instance.replace current }

    it { is_expected.to change { instance.changes }.from(changes).to(new_changes) }
    it { is_expected.to change { instance.changed? }.from(true).to(false) }
    it { is_expected.to change { instance.added }.from([fourth_mentionable]).to([]) }
    it { is_expected.to change { instance.removed }.from([first_mentionable]).to([]) }
    it { is_expected.to change { instance.previous }.from(previous).to(current) }
    it { is_expected.not_to change { instance.current }.from(current) }
  end
end
