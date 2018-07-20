module ActsAsMentionable
  class Configuration
    attr_accessor :mention_delimiter, :mention_regex

    def initialize
      @mention_delimiter = '@'
      @mention_regex = /\{#{mention_delimiter}\|[0-9]+\|[a-zA-Z0-9-_.]+\}/
    end
  end
end
