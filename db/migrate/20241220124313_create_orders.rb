class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :financial_status
      t.string :shopify_order_id
      t.string :order_number
      t.string :shopify_shop_id
      t.references :shop, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.float :total_line_items_price
      t.float :charity_price
      t.integer :charity_percentage
      t.timestamps
    end
  end
end
