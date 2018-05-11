Dir[File.join(File.dirname(__FILE__), 'asset/*.rb')].each {|file| require file }

module ITGlue
  module Asset
    class ITGlueAssetError < ITGlueError; end
    class ITGlueMethodNotAvailable < ITGlueAssetError; end
  end
end