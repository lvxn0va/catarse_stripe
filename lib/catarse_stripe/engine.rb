require "omniauth"
require "omniauth-stripe-connect"

module CatarseStripe
  class Engine < ::Rails::Engine
    isolate_namespace CatarseStripe
  end
end
