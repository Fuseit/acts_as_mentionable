module ActsAsMentionable
  class TransactionCallbacks
    class << self
      def on_committed &block
        if current_transaction.open?
          add_transaction_record new(block, nil)
        else
          yield
        end
      end

      def on_rolled_back &block
        add_transaction_record new(nil, block)
      end

      private

        def add_transaction_record record
          current_transaction.add_record record
        end

        def current_transaction
          Mention.connection.current_transaction
        end
    end

    attr_reader :on_committed_block, :on_rolled_back_block

    def initialize on_committed_block, on_rolled_back_block
      @on_committed_block = on_committed_block
      @on_rolled_back_block = on_rolled_back_block
    end

    def committed! _should_run_callbacks = true
      on_committed_block&.call
    end

    def rolledback! _force_restore_state = false, _should_run_callbacks = true
      on_rolled_back_block&.call
    end
  end
end
