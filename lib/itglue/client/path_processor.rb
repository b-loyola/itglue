module ITGlue
  class Client
    class PathProcessor
      def self.process(asset_type, options = {})
        self.new(asset_type, options).path
      end

      # @param asset_type [Symbol|String] the pluralized asset type name
      # @param options [Hash] valid options:
      #   parent [ITGlue::Asset] the parent instance
      #   id [Integer] the asset id
      def initialize(asset_type, options = {})
        @asset_type = asset_type
        @options = options
        @path_array = []
      end

      def path
        @path ||= path_array.unshift('').join('/')
      end

      private

      def parent
        @options[:parent]
      end

      def id
        @options[:id]
      end

      def path_array
        return @path_array if @processed
        append_parent if parent
        append_asset_type
        append_id if id
        @processed = true
        @path_array
      end

      def append_parent
        @path_array << parent.asset_type
        @path_array << parent.id
        @path_array << :relationships
      end

      def append_asset_type
        @path_array << @asset_type
      end

      def append_id
        @path_array << id
      end
    end
  end
end