class AddStripeIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_userid, :string
  end
end
