require 'active_support/core_ext/string/inflections'

module ITGlue
  module Asset
    class Base
      class << self
        # Override in subclasses if required
        def asset_type
          raise ITGlueAssetError.new('no asset_type for base') if self == Base
          self.name.demodulize.pluralize.underscore.to_sym
        end

        def parent(parent_type)
          @parent_type = parent_type
        end

        def nested_asset
          @nested_asset = true
        end

        def new_from_payload(data)
          raise_method_not_available(__method__, 'not available for Base') if self == Base
          asset = self.new(data[:attributes])
          asset.id = data[:id]
          asset.type = data[:type]
          asset
        end

        def get(options = {})
          raise_method_not_available(__method__, 'is nested asset') if nested_asset?
          assets = client.get(asset_type, {}, options)
          assets.map { |data| self.new_from_payload(data) }
        end

        def get_nested(parent, options = {})
          raise_method_not_available(__method__, 'is top-level asset') unless parent_type
          path_options = { parent: parent }
          assets = client.get(asset_type, path_options, options)
          assets.map { |data| self.new_from_payload(data) }
        end

        def find(id)
          data = client.get(asset_type, id: id )
          self.new_from_payload(data)
        end

        def filter(filter)
          raise_method_not_available(__method__, 'is nested asset') if nested_asset?
          assets = client.get(asset_type, {}, { query: { filter: filter } })
          assets.map { |data| self.new_from_payload(data) }
        end

        def client
          @@client ||= Client.new
        end

        protected

        def nested_asset?
          !!@nested_asset
        end

        def parent_type
          @parent_type
        end

        def raise_method_not_available(method_name, reason)
          error_msg = "method '#{method_name}' is not available for #{asset_type}: #{reason}"
          raise ITGlueMethodNotAvailable.new(error_msg)
        end
      end

      attr_accessor :id, :type

      def initialize(attributes = {})
        @attributes = Attributes.new(attributes)
        create_accessors(*@attributes.keys)
      end

      def asset_type
        self.class.asset_type
      end

      def inspect
        string = "#<#{self.class.name} id: #{self.id || 'nil'} "
        fields = @attributes.keys.map { |field| "#{field}: #{@attributes.inspect_field(field)}" }
        string << fields.join(", ") << ">"
      end

      def attributes
        @attributes.attributes
      end

      def [](attribute)
        @attributes[attribute]
      end

      def []=(attribute, value)
        create_accessors(attribute)
        self.send(attribute, value)
      end

      def changed_attributes
        @attributes.changes
      end

      def remove_attribute(key)
        @attributes.remove_attribute(key)
      end

      def new_asset?
        !self.id
      end

      def save
        new_asset? ? create : update
      end

      def changed?
        !changed_attributes.empty?
      end

      private

      def create
        data = client.post(asset_type, payload)
        reload_from_data(data)
      end

      def update
        data = client.patch(asset_type, payload, id: id )
        reload_from_data(data)
      end

      def payload
        {
          data: {
            type: asset_type,
            attributes: changed_attributes
          }
        }
      end

      def reload_from_data(data)
        @attributes = Attributes.new(data[:attributes])
        create_accessors(*@attributes.keys)
        self.type = data[:type]
        self.id = data[:id]
        self
      end

      def client
        self.class.client
      end

      def create_accessors(*attribute_names)
        attribute_names.each do |attribute_name|
          create_attr_reader(attribute_name)
          create_attr_writer(attribute_name)
        end
      end

      def create_attr_reader(attribute_name)
        define_singleton_method(attribute_name) do
          @attributes[attribute_name]
        end
      end

      def create_attr_writer(attribute_name)
        define_singleton_method("#{attribute_name}=") do |value|
          @attributes.assign_attribute(attribute_name, value)
        end
      end
    end
  end
end