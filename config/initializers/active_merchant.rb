ActiveMerchant::Billing::StripeGateway.default_currency = 'usd'
ActiveMerchant::Billing::Base.mode = :test if (::Configuration[:stripe_test] == 'true')