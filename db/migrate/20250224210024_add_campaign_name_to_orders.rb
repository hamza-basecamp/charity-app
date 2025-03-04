class AddCampaignNameToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :campaign_name, :string
  end
end
