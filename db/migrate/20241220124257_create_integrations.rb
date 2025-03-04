class CreateIntegrations < ActiveRecord::Migration[7.0]
  def change
    create_table :integrations do |t|
      t.references :shop, null: false, foreign_key: true
      t.string :temp_token
      t.string :unique_id
      t.string :auth_service
      t.string :token

      t.timestamps    end
  end
end
