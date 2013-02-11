Rails.configuration.stripe = {
  :publishable_key => (::Configuration['stripe_api_key']),
  :secret_key      => (::Configuration['stripe_secret_key'])
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]