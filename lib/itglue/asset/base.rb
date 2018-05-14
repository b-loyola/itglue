require 'active_support/core_ext/string/inflections'
require 'itglue/asset/base/relatable'
require 'itglue/asset/base/attributes'

module ITGlue
  module Asset
    class Base
      extend Relatable

      class << self
        # Override in subclasses if required
        def asset_type
          raise ITGlueAssetError.new('no asset_type for base') if self == Base
          self.name.demodulize.pluralize.underscore.to_sym
        end

        # Instantiates a record from data payload
        # @param data [Hash] the data payload
        #   E.g.: { id: 1, type: 'organizations', attributes: {name: 'Happy Frog', ...} }
        # @return [ITGlue::Asset] the record instance
        def new_from_payload(data)
          raise_method_not_available(__method__, 'not available for Base') if self == Base
          asset = self.new(data[:attributes])
          asset.id = data[:id]
          asset.type = data[:type]
          asset
        end

        # Executes a get request through the top-level path
        # E.g. GET '/configurations'
        # @return [Array<ITGlue::Asset>] an array of asset instances
        def get
          raise_method_not_available(__method__, 'is nested asset') if nested_asset?
          assets = client.get(asset_type)
          assets.map { |data| self.new_from_payload(data) }
        end

        # Executes a get request through the nested asset path
        # E.g. GET 'organizations/:organization_id/relationships/configurations'
        # @param parent [ITGlue::Asset] the parent asset
        # @return [Array<ITGlue::Asset>] an array of asset instances
        def get_nested(parent)
          raise_method_not_available(__method__, 'is top-level asset') unless parent_type
          path_options = { parent: parent }
          assets = client.get(asset_type, path_options)
          assets.map { |data| self.new_from_payload(data) }
        end

        # Executes a get request through the top-level path, with a filter query
        # E.g. GET '/configurations?filter[name]=HP-01'
        # @param filter [Hash|String] the parameters to filter by
        # @return [Array<ITGlue::Asset>] an array of asset instances
        def filter(filter)
          raise_method_not_available(__method__, 'is nested asset') if nested_asset?
          assets = client.get(asset_type, {}, { query: { filter: filter } })
          assets.map { |data| self.new_from_payload(data) }
        end

        # Executes a get request through the top-level path for a specific asset
        # E.g. GET '/configurations/1'
        # @param id [Integer] the id of the asset
        # @return [ITGlue::Asset] the asset instance
        def find(id)
          data = client.get(asset_type, id: id )
          self.new_from_payload(data)
        end

        def client
          @@client ||= Client.new
        end

        protected

        def raise_method_not_available(method_name, reason)
          error_msg = "method '#{method_name}' is not available for #{asset_type}: #{reason}"
          raise MethodNotAvailable.new(error_msg)
        end
      end

      attr_accessor :id, :type, :attributes

      def initialize(attributes = {})
        raise ITGlueAssetError.new('cannot instantiate base') if self == Base
        @attributes = Attributes.new(attributes)
      end

      def asset_type
        self.class.asset_type
      end

      def inspect
        string = "#<#{self.class.name} id: #{self.id || 'nil'} "
        fields = @attributes.keys.map { |field| "#{field}: #{@attributes.inspect_field(field)}" }
        string << fields.join(", ") << ">"
      end

      def dup
        dup = self.class.new(self.attributes)
        dup.type = self.type
        dup
      end

      def assign_attributes(attributes)
        raise ArgumentError.new('attributtes must be a Hash') unless attributes.is_a?(Hash)
        attributes.each do |attribute, value|
          @attributes[attribute] = value
        end
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

      def [](attribute)
        @attributes[attribute]
      end

      def []=(attribute, value)
        @attributes.assign_attribute(attribute, value)
      end

      def method_missing(method, *args)
        method_name = method.to_s
        arg_count = args.length
        if method_name.chomp!('=')
          raise ArgumentError.new("wrong number of arguments (#{arg_count} for 1)") if arg_count != 1
          @attributes.assign_attribute(method_name, args[0])
        elsif arg_count == 0
          @attributes[method]
        else
          super
        end
      end

      private

      def create
        data = self.class.client.post(asset_type, payload)
        reload_from_data(data)
      end

      def update
        data = self.class.client.patch(asset_type, payload, id: id )
        reload_from_data(data)
      end

      def payload
        {
          data: {
            type: asset_type,
            attributes: attributes.attributes_hash
          }
        }
      end

      def reload_from_data(data)
        @attributes = Attributes.new(data[:attributes])
        self.type = data[:type]
        self.id = data[:id]
        self
      end
    end
  end
end