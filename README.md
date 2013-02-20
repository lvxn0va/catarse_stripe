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

### Authorization

Users who will be creating projects can now create and connect a Stripe.com project payments account. This is the account that will receive funds for each project.  

Just above the #password field and in the My_Data section, add the following in `app/views/users/_current_user_fields.html.slim`:  
    
    ...
    #payment_gateways
    h1= t('.payment_gateways')
    ul
      li
        - if @user.stripe_key.blank?
          = link_to( image_tag('auth/stripe_blue.png'), '/payment/stripe/auth')
        - else
          = image_tag 'auth/stripe-solid.png'
          br
          p= t('.stripe_key_info')
          p= @user.stripe_key
          br
          p= t('.stripe_customer_info')
          p= @user.stripe_userid
          ...

This will create a button in the User/settings tab to connect to the catarse_stripe auth and get a UserID, Secretkey and PublicKey for the User/Project Owner. To copy those keys to the matchin columns in the projects table.  

Add this to the bottom of app/controllers/projects_controller.rb:

    def check_for_stripe_keys
      if @project.stripe_userid.nil?
        [:stripe_access_token, :stripe_key, :stripe_userid].each do |field|
          @project.send("#{field.to_s}=", @project.user.send(field).dup)
        end
      elsif @project.stripe_userid != @project.user.stripe_userid
        [:stripe_access_token, :stripe_key, :stripe_userid].each do |field|
          @project.send("#{field.to_s}=", @project.user.send(field).dup)
        end
      end
      @project.save
    end  

The insert `check_for_stripe_keys` in the :show method above 'show!'  like so:
    
    ...
    check_for_stripe_keys

      show!{
        @title = @project.name
        @rewards = @project.rewards.order(:minimum_value).all
        @backers = @project.backers.confirmed.limit(12).order("confirmed_at DESC").all
        fb_admins_add(@project.user.facebook_id) if @project.user.facebook_id
        @update = @project.updates.where(:id => params[:update_id]).first if params[:update_id].present?
      }
     ...

As well as in the :create method after the bitly section like so:  
    
    ...
    unless @project.new_record?
      @project.reload
      @project.update_attributes({ short_url: bitly })
    end
    check_for_stripe_keys
    ...

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
