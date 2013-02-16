#module CatarseStripe
  #class Engine < ::Rails::Engine
    #isolate_namespace CatarseStripe
  #end
#end
module ActionDispatch::Routing
  class Mapper
    def mount_catarse_stripe_at(catarse_stripe)
      scope :payment do
        get '/payment/stripe/:id/review' => 'catarse_stripe/payment/stripe#review', :as => 'payment_review_stripe'
        post '/payment/stripe/notifications' => 'catarse_stripe/payment/stripe#ipn',  :as => 'payment_ipn_stripe'
        match '/payment/stripe/:id/notifications' => 'catarse_stripe/payment/stripe#notifications',  :as => 'payment_notifications_stripe'
        match '/payment/stripe/:id/pay'           => 'catarse_stripe/payment/stripe#pay',            :as => 'payment_pay_stripe'
        match '/payment/stripe/:id/success'       => 'catarse_stripe/payment/stripe#success',        :as => 'payment_success_stripe'
        match '/payment/stripe/:id/cancel'        => 'catarse_stripe/payment/stripe#cancel',         :as => 'payment_cancel_stripe'
        match '/payment/stripe/:id/charge'        => 'catarse_stripe/payment/stripe#charge',         :as => 'payment_charge_stripe'
      end
    end
  end
end
