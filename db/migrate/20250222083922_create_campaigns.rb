
class CreateCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :campaigns do |t|
      t.string :category_id
      t.string :name
      t.integer :campaign_percentage
      t.boolean  :active, default: false

      t.timestamps
    end
  end
end
