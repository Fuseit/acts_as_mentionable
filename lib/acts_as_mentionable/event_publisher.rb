module ActsAsMentionable
  class EventPublisher
    attr_reader :mentioner, :changes

    def initialize mentioner, changes
      @mentioner = mentioner
      @changes = changes
    end

    def call
    end
  end
end
