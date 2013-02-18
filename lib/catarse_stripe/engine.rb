require "omniauth"
require "omniauth-stripe-connect"

module CatarseStripe
  class Engine < ::Rails::Engine
    isolate_namespace CatarseStripe

    config.to_prepare do
      ApplicationController.helper(MyEngineHelper)
    end
  end


end
