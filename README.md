# CatarseStripe

Catarse Stripe integration with [Catarse](http://github.com/danielweinmann/catarse) crowdfunding platform

## Installation

Add this lines to your Catarse application's Gemfile:

    gem 'catarse_stripe'

And then execute:

    $ bundle

## Usage

Configure the routes for your Catarse application. Add the following lines in the routes file (config/routes.rb):

    mount CatarseStripe::Engine => "/", :as => "catarse_stripe"

### Configurations

Create this configurations into Catarse database:

    stripe_api_key, stripe_secret_key and stripe_test (boolean)

In Rails console, run this:

    Configuration.create!(name: "stripe_api_key", value: "API_KEY")
    Configuration.create!(name: "stripe_secret_key", value: "SECRET_KEY")
    Configuration.create!(name: "stripe_test", value: "TRUE/FALSE")

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
