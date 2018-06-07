require File.join(File.dirname(__FILE__), 'asset/base.rb')
require File.join(File.dirname(__FILE__), 'asset/configuration.rb')
require File.join(File.dirname(__FILE__), 'asset/configuration_interface.rb')
require File.join(File.dirname(__FILE__), 'asset/configuration_status.rb')
require File.join(File.dirname(__FILE__), 'asset/configuration_type.rb')
require File.join(File.dirname(__FILE__), 'asset/organization.rb')

module ITGlue
  module Asset
    class ITGlueAssetError < ITGlueError; end
    class MethodNotAvailable < ITGlueAssetError; end
  end
end
