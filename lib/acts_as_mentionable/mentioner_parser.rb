module ActsAsMentionable
  class MentionerParser
    attr_reader :mentioner

    def initialize mentioner
      @mentioner = mentioner
    end

    def parse!
      mentionables = []
      new_mention_field = mentioner.send(mentioner.class.mention_parsed_field).gsub(template_for_parsing) do |template|
        _delimiter, mentionable_id, mentionable_klass = template.gsub(/[\{,\}]/, '').split('|')
        mentionable = retrieve_mentionable mentionable_klass, mentionable_id
        mentionables << mentionable if mentionable.respond_to?(:mentionable?) && mentionable.mentionable?
        metionable_template mentionable, template
      end
      mentioner.update_column(mentioner.class.mention_field, new_mention_field)
      mentionables
    end

    def retrieve_mentionable mentionable_klass, mentionable_id
      mentionable_klass.classify.constantize.find mentionable_id
    rescue NameError
      nil
    end

    private

      def template_for_parsing
        /\{@\|\d+\|\w+\}/
      end

      def metionable_template mentionable, template
        if mentionable.respond_to?(:mentionable?) && mentionable.mentionable?
          "*U+2063*@#{mentionable.send(mentionable.class.mentionable_field)}*U+2063*"
        else
          template
        end
      end
  end
end
