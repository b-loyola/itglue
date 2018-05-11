module ITGlue
  class Configuration < Asset::Base
    parent :organizations

    def configuration_interfaces
      ConfigurationInterfaces.all_for_parent(self)
    end
  end
end