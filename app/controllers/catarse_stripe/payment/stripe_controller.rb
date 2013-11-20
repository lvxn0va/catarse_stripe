require 'catarse_stripe/processors'
require 'json'
require 'stripe'
require 'oauth2'

module CatarseStripe::Payment
    class StripeController < ApplicationController
    
    skip_before_filter :verify_authenticity_token, :only => [:notifications]
    skip_before_filter :detect_locale, :only => [:notifications, :connect]
    skip_before_filter :set_locale, :only => [:notifications, :connect]
    skip_before_filter :force_http

    before_filter :setup_auth_gateway

    SCOPE = "projects.backers.checkout"
    AUTH_SCOPE = "users.auth"

    layout :false

    #Makes the call to @client.auth_code.authorize_url from auth.html.erg
    def auth
      @stripe_user = current_user
      respond_to do |format|
        format.html
        format.js
      end
    end

    #Brings back the authcode from Stripe and makes another call to Stripe to convert to a authtoken
    def callback
      @stripe_user = current_user
      code = params[:code]

      @response = @client.auth_code.get_token(code, {
      :headers => {'Authorization' => "Bearer #{::Configuration['stripe_secret_key']}"} #Platform Secret Key
      })
      
      #Save PROJECT owner's new keys
      @stripe_user.stripe_access_token = @response.token
      @stripe_user.stripe_key = @response.params['stripe_publishable_key']
      @stripe_user.stripe_userid = @response.params['stripe_user_id']
      @stripe_user.save

      
      return redirect_to payment_stripe_auth_path(@stripe_user)
    rescue Stripe::AuthenticationError => e
      ::Airbrake.notify({ :error_class => "Stripe #Pay Error", :error_message => "Stripe #Pay Error: #{e.inspect}", :parameters => params}) rescue nil
      Rails.logger.info "-----> #{e.inspect}"
      flash[:error] = e.message
      return redirect_to main_app.user_path(@stripe_user)
    end

    def review
    
    end

    def ipn
      #return render status: 200, nothing: true if (details.livemode == false && Rails.env.production? == true)
      stripe_key = User.find_by_stripe_userid(params[:user_id]).stripe_access_token
      details = Stripe::Event.retrieve(params[:id], stripe_key)
      if details.type == "charge.succeeded"
        confirm_backer(details,stripe_key)
      elsif details.type == "charge.refunded"
        refund_backer(details, stripe_key)
      end
      return render status: 200, nothing: true
    rescue Stripe::CardError => e
      ::Airbrake.notify({ :error_class => "Stripe Notification Error", :error_message => "Stripe Notification Error: #{e.inspect}", :parameters => params}) rescue nil
      return render status: 200, nothing: true
    end

    def confirm_backer(details, stripe_key)
      charge = details.data.object
      customer = Stripe::Customer.retrieve(charge.customer, stripe_key)
      backer = Backer.where(:payment_id => charge.id).first
      if backer
        notification = backer.payment_notifications.new({
          extra_data: customer.email
        })
        notification.save!
        backer.update_attribute(:payment_service_fee, (charge.amount * ::Configuration['catarse_fee'].to_f) / 100 )
        if charge.paid == true
          backer.confirm!
        end
      end
    end

    def refund_backer(details)
      charge = details.data.object
      backer = Backer.where(:payment_id => charge.id).first
      if backer
        backer.refund! if !backer.refunded?
      end
    end

    def notifications
      backer = Backer.find params[:id]
      details = Stripe::Charge.retrieve(
          id: backer.payment_id
          )
      if details.paid = true
        build_notification(backer, details)
        render status: 200, nothing: true
      else
        render status: 404, nothing: true
      end
    rescue Stripe::CardError => e
      ::Airbrake.notify({ :error_class => "Stripe Notification Error", :error_message => "Stripe Notification Error: #{e.inspect}", :parameters => params}) rescue nil
      render status: 404, nothing: true
    end
    
    def charge
      @backer = current_user.backs.find params[:id]
      access_token = @backer.project.stripe_access_token #Project Owner SECRET KEY

      respond_to do |format|
        format.html
        format.js
      end
    end 

    def pay
      @backer = current_user.backs.find params[:id]
      access_token = @backer.project.stripe_access_token #Project Owner SECRET KEY
      begin
        customer = Stripe::Customer.create(
        {
           email: @backer.payer_email,
           card: params[:stripeToken]
           },
        access_token
        )
        
        @backer.update_attributes(:payment_token => customer.id)
        @backer.save
        flash[:notice] = "Stripe Customer ID Saved!"

        response = Stripe::Charge.create(
          {
          customer: @backer.payment_token,
          amount: @backer.price_in_cents,
          currency: 'usd',
          description: t('stripe_description', scope: SCOPE, :project_name => @backer.project.name, :value => @backer.display_value),
          application_fee: (@backer.price_in_cents * ::Configuration['catarse_fee'].to_f).to_i
          },
          access_token #ACCESS_TOKEN (Stripe Secret Key of Connected Project Owner NOT platform)
        )

        @backer.update_attributes({
          :payment_method => 'Stripe',
          :payment_token => response.customer, #Stripe Backer Customer_id
          :payment_id => response.id, #Stripe Backer Payment Id
          :confirmed => response.paid #Paid = True, Confirmed =  true
        })
        @backer.save

        build_notification(@backer, response)
      
        redirect_to payment_success_stripe_url(id: @backer.id)
      rescue Stripe::CardError => e
        ::Airbrake.notify({ :error_class => "Stripe #Pay Error", :error_message => "Stripe #Pay Error: #{e.inspect}", :parameters => params}) rescue nil
        Rails.logger.info "-----> #{e.inspect}"
        flash[:error] = e.message
        return redirect_to main_app.new_project_backer_path(@backer.project)
      end
    end

    def success
      backer = current_user.backs.find params[:id]
      access_token = backer.project.stripe_access_token #Project Owner SECRET KEY
      begin
        details = Stripe::Charge.retrieve(
        {
          id: backer.payment_id
          },
          access_token
          )

        build_notification(backer, details)

        if details.id
          backer.update_attribute :payment_id, details.id
        end
        stripe_flash_success
        redirect_to main_app.project_backer_path(project_id: backer.project.id, id: backer.id)
      rescue Stripe::CardError => e
        ::Airbrake.notify({ :error_class => "Stripe Error", :error_message => "Stripe Error: #{e.message}", :parameters => params}) rescue nil
        Rails.logger.info "-----> #{e.inspect}"
        flash[:error] = e.message
        return redirect_to main_app.new_project_backer_path(backer.project)
      end
    end

    def cancel
      backer = current_user.backs.find params[:id]
      flash[:failure] = t('stripe_cancel', scope: SCOPE)
      redirect_to main_app.new_project_backer_path(backer.project)
    end

  private
    #Setup the Oauth2 Stripe call with needed params - See initializers.stripe..rb..the Stripe keys are setup in the seed.db or added manually with a Configuration.create! call.
    def setup_auth_gateway
      session[:oauth] ||= {}

      @client = OAuth2::Client.new((::Configuration['stripe_client_id']), (::Configuration['stripe_access_token']), {
        :site => 'https://connect.stripe.com',
        :authorize_url => '/oauth/authorize',
        :token_url => '/oauth/token'
      })
    end

    def build_notification(backer, data)
      processor = CatarseStripe::Processors::Stripe.new
      processor.process!(backer, data)
    end

    def stripe_flash_error
      flash[:failure] = t('stripe_error', scope: SCOPE)
    end

    def stripe_flash_success
      flash[:success] = t('success', scope: SCOPE)
    end

    def stripe_auth_flash_error
      flash[:failure] = t('stripe_error', scope: AUTH_SCOPE)
    end

    def stripe_auth_flash_success
      flash[:success] = t('success', scope: AUTH_SCOPE)
    end
  end
end