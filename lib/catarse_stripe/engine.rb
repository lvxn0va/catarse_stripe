#module CatarseStripe
  #class Engine < ::Rails::Engine
    #isolate_namespace CatarseStripe
  #end
#end
module ActionDispatch::Routing
  class Mapper
    def mount_catarse_stripe_at(mount_location)
      scope mount_location do
          get 'payment/stripe/:id/review' => 'payment/stripe#review', :as => 'review_stripe'
          post 'payment/stripe/notifications' => 'payment/stripe#ipn',  :as => 'ipn_stripe'
          match 'payment/stripe/:id/notifications' => 'payment/stripe#notifications',  :as => 'notifications_stripe'
          match 'payment/stripe/:id/pay'           => 'payment/stripe#pay',            :as => 'pay_stripe'
          match 'payment/stripe/:id/success'       => 'payment/stripe#success',        :as => 'success_stripe'
          match 'payment/stripe/:id/cancel'        => 'paymentstripe#cancel',         :as => 'cancel_stripe'
          match 'payment/stripe/:id/charge'        => 'paymentstripe#charge',         :as => 'charge_stripe'
      end
    end
  end
end
