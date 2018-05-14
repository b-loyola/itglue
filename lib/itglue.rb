module ITGlue
  class ITGlueError < StandardError; end

  class << self
    attr_writer :config

    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
      config
    end
  end

  class Config
    DEFAULT_PAGE_SIZE = 500
    attr_accessor :itglue_api_key, :itglue_api_base_uri, :logger, :default_page_size

    def initialize
      @default_page_size = DEFAULT_PAGE_SIZE
    end
  end
end

require 'itglue/version'
require 'itglue/client'
require 'itglue/asset'