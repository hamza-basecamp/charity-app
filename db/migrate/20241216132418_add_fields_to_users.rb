class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :company_name, :string
    add_column :users, :tax_number, :string
    add_column :users, :description, :string
    add_column :users, :ein_number, :string
    add_column :users, :account_number, :string
    add_column :users, :bank_type, :string
    add_column :users, :image, :string  # Assuming image is stored as a URL or filename
    add_column :users, :image_id, :string
    add_column :users, :location, :string
    add_column :users, :postal_address, :string
  end
end
