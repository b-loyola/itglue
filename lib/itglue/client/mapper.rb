require 'active_support/core_ext/string/inflections'

module ITGlue
  class Client
    class Mapper
      def self.map(raw_data)
        self.new(raw_data).format
      end

      def initialize(raw_data)
        @raw_data = raw_data
      end

      def format
        collection? ? format_collection(@raw_data) : format_object(@raw_data)
      end

      private

      def collection?
        @raw_data.is_a?(Array)
      end

      def format_collection(data)
        data.map { |d| format_object(d) }
      end

      def format_object(data)
        {
          id:         data['id'].to_i,
          type:       data['type'],
          attributes: transform_keys(data['attributes'])
        }
      end

      def transform_keys(attributes)
        attributes.map { |key, value| [key.underscore.to_sym, value] }.to_h
      end
    end
  end
end