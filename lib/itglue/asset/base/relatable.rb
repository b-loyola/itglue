module ITGlue
  module Asset
    module Relatable
      def parent(parent_type, options = {})
        @parent_type = parent_type.to_s.pluralize
        unless options[:no_association]
          define_method parent_type do
            parent_id = self.send("#{parent_type}_id")
            "ITGlue::#{parent_type.to_s.classify}".constantize.find(parent_id)
          end
        end
      end

      def children(*child_types)
        child_types.each do |child_type|
          define_method child_type do |options = {}|
            "ITGlue::#{child_type.to_s.classify}".constantize.get_nested(self, options)
          end
        end
      end

      protected

      def nested_asset
        @nested_asset = true
      end

      def nested_asset?
        !!@nested_asset
      end

      def parent_type
        @parent_type
      end
    end
  end
end