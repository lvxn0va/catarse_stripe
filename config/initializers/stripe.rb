Rails.configuration.stripe = {
  :publishable_key => (::Configuration['stripe_api_key']),
  :secret_key      => (::Configuration['stripe_secret_key']),
  :stripe_client_id => (::Configuration['stripe_client_id'])
}

#Stripe.api_key = Rails.configuration.stripe[:secret_key]
#STRIPE_PUBLIC_KEY = Rails.configuration.stripe[:publishable_key]
#STRIPE_CLIENT_ID = Rails.configuration.stripe[:stripe_client_id]

Stripe.api_key = @project.stripe_access_token #secret
STRIPE_PUBLIC_KEY = @project.stripe_key #publishable
STRIPE_CLIENT_ID = Rails.configuration.stripe[:stripe_client_id]