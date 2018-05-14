module ITGlue
  class ConfigurationInterface < Asset::Base
    parent :configuration, no_association: true
    nested_asset
  end
end