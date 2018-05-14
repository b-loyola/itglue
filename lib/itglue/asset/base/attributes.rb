module ITGlue
  module Asset
    class Attributes < OpenStruct
      def initialize(*args)
        @changed_attribute_keys = []
        super
      end

      def assign_attribute(key, value)
        @changed_attribute_keys << key.to_sym
        self[key] = value
      end

      def remove_attribute(key)
        @changed_attribute_keys.delete(key)
        self.delete_field(key)
      end

      def keys
        self.to_h.keys
      end

      def attributes_hash
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
        attributes_hash = self.attributes_hash
        @changed_attribute_keys.each_with_object({}) do |key, changes|
          changes[key] = attributes_hash[key]
        end
      end
    end
  end
end