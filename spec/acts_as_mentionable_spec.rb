RSpec.describe ActsAsMentionable do
  it 'has a version number' do
    expect(ActsAsMentionable::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end

  it { expect { described_class::Mention }.not_to raise_error }
  it { expect { described_class::MentionablesManipulator }.not_to raise_error }
  it { expect { described_class::MentionsUpdater }.not_to raise_error }
  it { expect { described_class::Mentionable }.not_to raise_error }
  it { expect { described_class::Mentioner }.not_to raise_error }
  it { expect { described_class::ActiveRecordMethods }.not_to raise_error }
  it { expect { described_class::RetrievePolymorphic }.not_to raise_error }
  it { expect { described_class::TransactionCallbacks }.not_to raise_error }

  it { expect(ActiveRecord::Base).to include described_class::ActiveRecordMethods }
end
