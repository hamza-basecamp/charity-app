class CreateStoreCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :store_customers do |t|
      t.string :email,   unique: true
      t.string :name
      t.string :order_number
      t.references :shop, null: false, foreign_key: true
      t.timestamps
    end
  end
end
