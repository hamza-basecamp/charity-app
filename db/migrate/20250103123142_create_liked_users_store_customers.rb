class CreateLikedUsersStoreCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :liked_users_store_customers do |t|
      t.references :store_customer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # Shorten the index name
    add_index :liked_users_store_customers, [:store_customer_id, :user_id], name: 'index_luscs_on_store_customer_and_user'
  end
end
