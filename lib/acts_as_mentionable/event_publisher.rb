module ActsAsMentionable
  class EventPublisher
    include Wisper::Publisher

    attr_reader :mentioner, :changes

    def initialize mentioner, changes
      @mentioner = mentioner
      @changes = changes
    end

    def call
      changes[:added].each { |mentionable| broadcast_mentionable_events mentionable, :added }
      changes[:removed].each { |mentionable| broadcast_mentionable_events mentionable, :removed }
    end

    private

      def broadcast_mentionable_events mentionable, type
        general_event_name = "mentionable_#{type}".to_sym
        mentionable_event_name = "#{mentionable.class.model_name.singular}_mention_#{type}".to_sym
        mentionable_method_name = "on_#{general_event_name}".to_sym

        publish general_event_name, mentionable, mentioner
        publish mentionable_event_name, mentionable, mentioner
        mentionable.public_send mentionable_method_name, mentioner if mentionable.respond_to? mentionable_method_name
      end
  end
end
