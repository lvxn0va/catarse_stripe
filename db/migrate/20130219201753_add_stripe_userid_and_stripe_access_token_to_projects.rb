class AddStripeUseridAndStripeAccessTokenToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :stripe_userid, :string
    add_column :projects, :stripe_access_token, :string
  end
end
