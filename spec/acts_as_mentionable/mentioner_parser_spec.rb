RSpec.describe ActsAsMentionable::MentionerParser do
  let(:mentionable) { MentionableModel.create! username: 'test' }
  let(:mentioner) do
    MentionerModel.create! parsed_body: "test {@|#{mentionable.id}|mentionable_model} and {@|123|wrong_model}|}"
  end

  describe '#parse' do
    subject(:parsed_mentionables) { described_class.new(mentioner).parse! }

    let(:expected_body) { 'test *U+200B*@test*U+200B* and {@|123|wrong_model}|}' }

    it { expect { parsed_mentionables }.to change { mentioner.reload.body }.to(expected_body) }
    it { is_expected.to include mentionable }
  end
end
