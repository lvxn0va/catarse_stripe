## The stripe_controller is a work in progress and things will be changing very rapidly. BEWARE!
### Tests are non-functional at this point and will be adjusted to Stripe soon!

# CatarseStripe

Catarse Stripe integration with [Catarse](http://github.com/danielweinmann/catarse) crowdfunding platform. 

So far, catarse_stripe uses Omniauth for an auth connection and to use Catarse as a Platform app. See the wiki on how to use Stripe-Connect.

## Installation

Add this lines to your Catarse application's Gemfile under the payments section:

    gem 'catarse_stripe', :git => 'git://github.com/lvxn0va/catarse_stripe.git'
    gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

And then execute:

    $ bundle

Install the database migrations

    bundle exec rake catarse_stripe:install:migrations
    bundle exec rake db:migrate
    
## Usage

Configure the routes for your Catarse application. Add the following lines in the routes file (config/routes.rb):

    mount CatarseStripe::Engine => "/", :as => "catarse_stripe"

### Configurations  

Signup for an account at [STRIPE PAYMENTS](http://www.stripe.com) - Go into your account settings and get your API Keys - Be sure to use your 'Test' keys until you're ready to go live. Alos make sure the live/test toggle in the Dashboard is appropriately set.

Create this configurations into Catarse database:

    stripe_api_key, stripe_secret_key and stripe_test (boolean)

In Rails console, run this:

    Configuration.create!(name: "stripe_api_key", value: "API_KEY")
    Configuration.create!(name: "stripe_secret_key", value: "SECRET_KEY")
    Configuration.create!(name: "stripe_test", value: "TRUE/FALSE")
    
If you've already created your application and been approved at Stripe.com add your Client_id  
    Configuration.create!(name: "stripe_client_id", value: "STRIPE_CLIENT_ID")

    NOTE: Be sure to add the correct keys from the API section of your Stripe account settings. Stripe_Test: TRUE = Using Stripe Test Server/Sandbox Mode / FALSE = Using Stripe live server.  

## Development environment setup

Clone the repository:

    $ git clone git://github.com/lvxn0va/catarse_stripe.git

Add the catarse code into test/dummy:

    $ git submodule init
    $ git submodule update

And then execute:

    $ bundle

## Troubleshooting in development environment

Remove the admin folder from test/dummy application to prevent a weird active admin bug:

    $ rm -rf test/dummy/app/admin

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


This project rocks and uses MIT-LICENSE.
