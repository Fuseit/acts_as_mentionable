module ActsAsMentionable
  class RetrievePolymorphic
    attr_reader :relation, :polymorphic_association_name

    def initialize relation, polymorphic_association_name
      @relation = relation
      @polymorphic_association_name = polymorphic_association_name
    end

    def call
      type_to_ids.map { |type, ids| type.constantize.unscoped.find ids }.flatten
    end

    private

      def type_and_id_list
        relation.pluck "#{polymorphic_association_name}_type", "#{polymorphic_association_name}_id"
      end

      def type_to_ids
        type_and_id_list.group_by(&:first).each_with_object({}) do |(type, type_and_id), hash|
          hash[type] = type_and_id.map(&:last)
        end
      end
  end
end
