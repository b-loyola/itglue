module ITGlue
  module Asset
    class Attributes < OpenStruct
      TIMESTAMPS = [:created_at, :updated_at].freeze

      def initialize(*args)
        @changed_attribute_keys = []
        super
      end

      def assign_attribute(key, value)
        @changed_attribute_keys << key
        self[key] = value
      end

      def remove_attribute(key)
        @changed_attribute_keys.delete(key)
        self.delete_field(key)
      end

      def keys
        self.to_h.keys
      end

      def keys_to_be_updated
        @changed_attribute_keys - TIMESTAMPS
      end

      def attributes
        self.to_h
      end

      def inspect_field(field)
        value = self[field]
        if value.is_a?(String)
          value.length > 100 ? "\"#{value[0..100]}...\"" : "\"#{value}\""
        else
          value.inspect
        end
      end

      def changes
        attributes_hash = attributes
        keys_to_be_updated.each_with_object({}) do |key, changes|
          changes[key] = attributes_hash[key]
        end
      end
    end
  end
end