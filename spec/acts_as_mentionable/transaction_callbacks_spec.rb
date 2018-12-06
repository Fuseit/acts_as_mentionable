RSpec.describe ActsAsMentionable::TransactionCallbacks, skip_transactions: true do
  let(:block) { -> { block_spy.invoke } }
  let(:block_spy) { spy }
  let(:connection) { ActsAsMentionable::Mention.connection }
  let(:current_transaction) { connection.current_transaction }

  describe '.on_committed' do
    subject do
      use_transaction ? invoke_within_transaction : invoke_without_transaction
      block_spy
    end

    let(:use_transaction) { true }
    let(:rollback) { false }

    let :invoke_without_transaction do
      described_class.on_committed(&block)
    end

    let :invoke_within_transaction do
      connection.transaction do
        invoke_without_transaction
        raise ActiveRecord::Rollback if rollback
      end
    end

    it { is_expected.to have_received :invoke }

    context 'when current transaction is rolled back' do
      let(:rollback) { true }

      it { is_expected.not_to have_received :invoke }
    end

    context 'when transaction is absent' do
      let(:use_transaction) { false }

      it { is_expected.to have_received :invoke }
    end
  end

  describe '.on_rolled_back' do
    subject do
      connection.transaction do
        described_class.on_rolled_back(&block)
        raise ActiveRecord::Rollback if rollback
      end

      block_spy
    end

    let(:rollback) { true }

    it { is_expected.to have_received :invoke }

    context 'when current transaction is committed' do
      let(:rollback) { false }

      it { is_expected.not_to have_received :invoke }
    end
  end
end
