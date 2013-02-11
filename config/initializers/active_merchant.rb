ActiveMerchant::Billing::StripeGateway.currency = 'usd'
ActiveMerchant::Billing::Base.mode = :test if (::Configuration[:stripe_test] == 'true')