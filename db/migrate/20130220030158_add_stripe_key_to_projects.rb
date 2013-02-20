class AddStripeKeyToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :stripe_key, :string
  end
end
