#module CatarseStripe
  #class Engine < ::Rails::Engine
    #isolate_namespace CatarseStripe
  #end
#end
module ActionDispatch::Routing
  class Mapper
    def mount_catarse_stripe_at(catarse_stripe)
      namespace :payment do
        get '/stripe/:id/review' => 'catarse_stripe/payment/stripe#review', :as => 'review_stripe'
        post '/stripe/notifications' => 'catarse_stripe/payment/stripe#ipn',  :as => 'ipn_stripe'
        match '/stripe/:id/notifications' => 'catarse_stripe/payment/stripe#notifications',  :as => 'notifications_stripe'
        match '/stripe/:id/pay'           => 'catarse_stripe/payment/stripe#pay',            :as => 'pay_stripe'
        match '/stripe/:id/success'       => 'catarse_stripe/payment/stripe#success',        :as => 'success_stripe'
        match '/stripe/:id/cancel'        => 'catarse_stripe/payment/stripe#cancel',         :as => 'cancel_stripe'
        match '/stripe/:id/charge'        => 'catarse_stripe/payment/stripe#charge',         :as => 'charge_stripe'
      end
    end
  end
end
