module CatarseStripe
  module Processors
    class Stripe

      def process!(backer, data)
        status = data["checkout_status"] || "pending"

        notification = backer.payment_notifications.new({
          extra_data: data
        })

        notification.save!

        backer.confirm! if success_payment?(status)
      rescue Exception => e
        ::Airbrake.notify({ :error_class => "Stripe Processor Error", :error_message => "Stripe Processor Error: #{e.inspect}", :parameters => data}) rescue nil
      end

      protected

      def success_payment?(status)
        status == 'PaymentActionCompleted'
      end

    end
  end
end