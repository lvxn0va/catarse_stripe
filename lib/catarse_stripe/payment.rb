require "catarse_stripe/engine"

module Payment
    mattr_accessor :user_class, :current_user

    def self.user_class
     @@user_class.constantize
    end

    def self.current_user
     send(@@current_user)
    end

end