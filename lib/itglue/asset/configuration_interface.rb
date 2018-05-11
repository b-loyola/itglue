module ITGlue
  class ConfigurationInterface < Asset::Base
    parent :configurations
    nested_asset
  end
end