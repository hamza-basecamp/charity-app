class AddCampaignToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :campaign_ids, :integer, array: true, default: []
  end
end
