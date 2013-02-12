require 'catarse_stripe/processors'

module CatarseStripe::Payment
    class StripeController < ApplicationController

    skip_before_filter :verify_authenticity_token, :only => [:notifications]
    skip_before_filter :detect_locale, :only => [:notifications]
    skip_before_filter :set_locale, :only => [:notifications]
    skip_before_filter :force_http

    #before_filter :setup_gateway

    SCOPE = "projects.backers.checkout"

    layout :false

    def review
    
    end

    def ipn
      backer = Backer.where(:payment_id => params['txn_id']).first
      if backer
        notification = backer.payment_notifications.new({
          extra_data: JSON.parse(params.to_json.force_encoding(params['charset']).encode('utf-8'))
        })
        notification.save!
        backer.update_attributes({
          :payment_service_fee => params['mc_fee'],
          :payer_email => params['payer_email']
        })
      end
      return render status: 200, nothing: true
    rescue Exception => e
      ::Airbrake.notify({ :error_class => "Stripe Notification Error", :error_message => "Stripe Notification Error: #{e.inspect}", :parameters => params}) rescue nil
      return render status: 200, nothing: true
    end

    def notifications
      backer = Backer.find params[:id]
      response = @@gateway.details_for(backer.payment_token)
      if response.params['transaction_id'] == params['txn_id']
        build_notification(backer, response.params)
        render status: 200, nothing: true
      else
        render status: 404, nothing: true
      end
    rescue Exception => e
      ::Airbrake.notify({ :error_class => "Stripe Notification Error", :error_message => "Stripe Notification Error: #{e.inspect}", :parameters => params}) rescue nil
      render status: 404, nothing: true
    end

    def pay
      backer = current_user.backs.find params[:id]
      begin
        customer = Stripe::Customer.create(
          email: backer.payer_email,
          card: params[:stripeToken]
        )

        response = Stripe::Charge.create(
          customer: customer.id,
          amount: backer.price_in_cents,
          currency: 'usd',
          description: t('stripe_description', scope: SCOPE, :project_name => backer.project.name, :value => backer.display_value)
        )

        backer.update_attribute :payment_method, 'Stripe'
        backer.update_attribute :payment_token, response.id

        build_notification(backer, response.params)

        redirect_to payment_success_stripe_url(id: backer.id)
      rescue Exception => e
        ::Airbrake.notify({ :error_class => "Paypal Error", :error_message => "Paypal Error: #{e.inspect}", :parameters => params}) rescue nil
        Rails.logger.info "-----> #{e.inspect}"
        stripe_flash_error
        return redirect_to main_app.new_project_backer_path(backer.project)
      end
    end

    def success
      backer = current_user.backs.find params[:id]
      begin
        @@gateway.purchase(backer.price_in_cents, {
          ip: request.remote_ip,
          token: backer.payment_token,
          payer_id: params[:PayerID]
        })

        # we must get the deatils after the purchase in order to get the transaction_id
        details = @@gateway.details_for(backer.payment_token)

        build_notification(backer, details.params)

        if details.params['transaction_id'] 
          backer.update_attribute :payment_id, details.params['transaction_id']
        end
        paypal_flash_success
        redirect_to main_app.thank_you_project_backer_path(project_id: backer.project.id, id: backer.id)
      rescue Exception => e
        ::Airbrake.notify({ :error_class => "Stripe Error", :error_message => "Stripe Error: #{e.message}", :parameters => params}) rescue nil
        Rails.logger.info "-----> #{e.inspect}"
        paypal_flash_error
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