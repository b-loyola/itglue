require 'httparty'
require 'itglue/client/mapper'
require 'itglue/client/path_processor'

module ITGlue
  class ClientError < ITGlueError; end
  class AssetNotFoundError < ClientError; end
  class ServerError < ClientError; end
  class UnexpectedResponseError < ClientError; end

  class Client
    include HTTParty

    def initialize
      raise ClientError.new('itglue_api_key not configured') unless ITGlue.config.itglue_api_key
      raise ClientError.new('itglue_api_base_uri not configured') unless ITGlue.config.itglue_api_base_uri
      @itglue_api_key    = ITGlue.config.itglue_api_key
      @default_page_size = ITGlue.config.default_page_size
      self.class.base_uri  ITGlue.config.itglue_api_base_uri
      self.class.logger    ITGlue.config.logger
    end

    def execute(http_method, path, payload = nil, options = {})
      process_request(http_method, path, payload, options)
    end

    def get(asset_type, path_options = {} ,options = {})
      response = process_request(:get, process_path(asset_type, path_options), nil, options)
      data = get_remaining_data(response, options)
      prepare_data(data)
    end

    def patch(asset_type, payload, path_options = {}, options = {})
      response = process_request(:patch, process_path(asset_type, path_options), payload, options)
      prepare_data(response['data'])
    end

    def post(asset_type, payload, path_options = {}, options = {})
      response = process_request(:post, process_path(asset_type, path_options), payload, options)
      prepare_data(response['data'])
    end

    private

    def get_remaining_data(response, options)
      return response['data'] unless response['data'].is_a?(Array)
      data = response['data']
      loop do
        return data if response['meta'] && response['meta']['next-page'].nil?
        response = process_request(:get, response['links']['next'], nil, options)
        data += response['data']
        break if response['meta'] && response['meta']['next-page'].nil?
      end
      data
    end

    def default_headers
      @default_headers ||= {
        'Content-Type' => 'application/vnd.api+json',
        'x-api-key' => @itglue_api_key
      }
    end

    def process_path(asset_type, path_options)
      PathProcessor.process(asset_type, path_options)
    end

    def prepare_data(data)
      Mapper.map(data)
    end

    def process_request(http_method, path, payload, options)
      options = process_options(options, payload)
      response = self.class.send(http_method, path, options)
      response.success? ? response : handle_response_errors(response)
    end

    def process_options(options, payload)
      options.merge!(body: payload.to_json) if payload
      if options[:headers]
        unless options[:headers].is_a?(Hash)
          raise ClientError.new('header option must be a Hash')
        end
        options[:headers] = default_headers.merge(options[:headers])
      else
        options[:headers] = default_headers
      end
      if options[:query]
        if options[:query][:page]
          unless options[:query][:page].is_a?(Hash)
            raise ClientError.new('page option must be a Hash')
          end
          options[:query][:page][:size] ||= @default_page_size
        else
          options[:query][:page] = { size: @default_page_size }
        end
      else
        options[:query] = { page: { size: @default_page_size } }
      end
      options
    end

    def handle_response_errors(response)
      if response.not_found?
        raise AssetNotFoundError.new(error_message(response))
      elsif response.client_error?
        raise ClientError.new(error_message(response))
      elsif response.server_error?
        raise ServerError.new(error_message(response))
      else
        raise UnexpectedResponseError.new(error_message(response))
      end
    end

    def error_message(response)
      message = "Request failed with error code #{response.code}"
      response.nil? ? message : "#{message} and body: #{response.parsed_response}"
    end
  end
end
