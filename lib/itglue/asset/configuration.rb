module ITGlue
  class Configuration < Asset::Base
    parent :organization
    children :configuration_interfaces
  end
end