class AddStripeAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_access_token, :string
  end
end
