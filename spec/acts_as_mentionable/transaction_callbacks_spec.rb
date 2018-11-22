RSpec.describe ActsAsMentionable::TransactionCallbacks do
  let(:block) { -> { block_spy.invoke } }
  let(:block_spy) { spy }
  let(:connection) { ActsAsMentionable::Mention.connection }
  let(:current_transaction) { connection.current_transaction }

  describe '.on_committed' do
    subject :on_committed_block_spy do
      connection.transaction do
        allow(current_transaction).to receive(:open?).and_return(transaction_open)

        described_class.on_committed(&block)

        raise ActiveRecord::Rollback if rollback
      end

      block_spy
    end

    let(:rollback) { false }
    let(:transaction_open) { true }

    it { is_expected.to have_received :invoke }

    context 'when current transaction is rolled back' do
      let(:rollback) { true }

      it { is_expected.not_to have_received :invoke }
    end

    context 'when current transaction is closed' do
      let(:transaction_open) { false }
      let(:rollback) { true }

      it { is_expected.to have_received :invoke }
    end
  end

  describe '.on_rolled_back' do
    subject :on_rolled_back_block_spy do
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
