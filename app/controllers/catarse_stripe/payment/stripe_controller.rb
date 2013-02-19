require 'catarse_stripe/processors'
require 'json'

module CatarseStripe::Payment
    class StripeController < ApplicationController
    
    skip_before_filter :verify_authenticity_token, :only => [:notifications]
    skip_before_filter :detect_locale, :only => [:notifications, :connect]
    skip_before_filter :set_locale, :only => [:notifications, :connect]
    skip_before_filter :force_http

    #Disable ActiveMerchant::Stripe in favor of Stripe gem
    #before_filter :setup_gateway

    SCOPE = "projects.backers.checkout"
    SCOPE = "users.projects"

    layout :false

    
    def connect
      @user = current_user

      respond_to do |format|
        format.html
        format.js
      end
    end

    #def auth
      #if @user.stripe_key.present?
        #render :text => "You have already connected a Stripe account. Your Stripe Key is #{@user.stripe_key}."
      #end
    #end

    def review
    
    end

    def ipn
      backer = Backer.where(:payment_id => details.id).first
      if backer
        notification = backer.payment_notifications.new({
          extra_data: JSON.parse(params.to_json.force_encoding(params['charset']).encode('utf-8'))
        })
        notification.save!
        backer.update_attribute :payment_service_fee => details.fee
      end
      return render status: 200, nothing: true
    rescue Stripe::CardError => e
      ::Airbrake.notify({ :error_class => "Stripe Notification Error", :error_message => "Stripe Notification Error: #{e.inspect}", :parameters => params}) rescue nil
      return render status: 200, nothing: true
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
      backer = current_user.backs.find params[:id]

      respond_to do |format|
        format.html
        format.js
      end
    end 

    def pay
      backer = current_user.backs.find params[:id]
      access_token = backer.project.stripe_key
      begin
        customer = Stripe::Customer.create(
          email: backer.payer_email,
          card: params[:stripeToken]
        )

        response = Stripe::Charge.create(
          {
          card: customer.card
          #customer: customer.id,
          amount: backer.price_in_cents,
          currency: 'usd',
          description: t('stripe_description', scope: SCOPE, :project_name => backer.project.name, :value => backer.display_value),
          application_fee: backer.platform_fee.to_i
          },
          access_token #ACCESS_TOKEN (Stripe Secret Key of Connected Project Owner NOT platform)
        )

        backer.update_attributes({
          :payment_method => 'Stripe',
          :payment_token => response.customer, #Stripe Backer Customer_id
          :payment_id => response.id, #Stripe Backer Payment Id
          :confirmed => response.paid #Paid = True, Confirmed =  true
        })
        backer.save

        build_notification(backer, response)
      
        redirect_to payment_success_stripe_url(id: backer.id)
      rescue Stripe::CardError => e
        ::Airbrake.notify({ :error_class => "Stripe #Pay Error", :error_message => "Stripe #Pay Error: #{e.inspect}", :parameters => params}) rescue nil
        Rails.logger.info "-----> #{e.inspect}"
        flash[:error] = e.message
        return redirect_to main_app.new_project_backer_path(backer.project)
      end
    end

    def success
      backer = current_user.backs.find params[:id]
      begin
        details = Stripe::Charge.retrieve(
          id: backer.payment_id
          )

        build_notification(backer, details)

        if details.id
          backer.update_attribute :payment_id, details.id
        end
        stripe_flash_success
        redirect_to main_app.thank_you_project_backer_path(project_id: backer.project.id, id: backer.id)
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

    def setup_gateway
      if ::Configuration[:stripe_api_key]# and ::Configuration[:stripe_secret_key]
        @@gateway ||= ActiveMerchant::Billing::StripeGateway.new({
          :login => ::Configuration[:stripe_api_key]
          #:login => ::Configuration[:stripe_secret_key]
        })
      else
        puts "[Stripe] API key is required to make requests to Stripe"
      end
    end
  end
end