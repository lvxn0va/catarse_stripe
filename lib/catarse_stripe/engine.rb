#module CatarseStripe
  #class Engine < ::Rails::Engine
    #isolate_namespace CatarseStripe
  #end
#end
module ActionDispatch::Routing
  class Mapper
    def mount_catarse_stripe_at(payment)
      scope payment do
          get '/stripe/:id/review' => 'stripe#review', :as => 'review_stripe'
          post '/stripe/notifications' => 'stripe#ipn',  :as => 'ipn_stripe'
          match '/stripe/:id/notifications' => 'stripe#notifications',  :as => 'notifications_stripe'
          match '/stripe/:id/pay'           => 'stripe#pay',            :as => 'pay_stripe'
          match '/stripe/:id/success'       => 'stripe#success',        :as => 'success_stripe'
          match '/stripe/:id/cancel'        => 'stripe#cancel',         :as => 'cancel_stripe'
          match '/stripe/:id/charge'        => 'stripe#charge',         :as => 'charge_stripe'
      end
    end
  end
end
