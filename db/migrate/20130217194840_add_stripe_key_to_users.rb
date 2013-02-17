class AddStripeKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_key, :string
  end
end
