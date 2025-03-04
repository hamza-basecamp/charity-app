# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_03_03_071211) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "category_id"
    t.string "name"
    t.integer "campaign_percentage"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "integrations", force: :cascade do |t|
    t.bigint "shop_id", null: false
    t.string "temp_token"
    t.string "unique_id"
    t.string "auth_service"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_integrations_on_shop_id"
  end

  create_table "liked_users_store_customers", force: :cascade do |t|
    t.bigint "store_customer_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_customer_id", "user_id"], name: "index_luscs_on_store_customer_and_user"
    t.index ["store_customer_id"], name: "index_liked_users_store_customers_on_store_customer_id"
    t.index ["user_id"], name: "index_liked_users_store_customers_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "financial_status"
    t.string "shopify_order_id"
    t.string "order_number"
    t.string "shopify_shop_id"
    t.bigint "shop_id", null: false
    t.bigint "user_id", null: false
    t.float "total_line_items_price"
    t.float "charity_price"
    t.integer "charity_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "campaign_name"
    t.index ["shop_id"], name: "index_orders_on_shop_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "store_customers", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "order_number"
    t.bigint "shop_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_store_customers_on_shop_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "approved", default: false
    t.string "commission_type", default: ""
    t.string "commission_rate", default: ""
    t.string "name", default: ""
    t.string "user_type", default: "charity"
    t.integer "financial_status", default: 0, null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_name"
    t.string "tax_number"
    t.string "description"
    t.string "ein_number"
    t.string "account_number"
    t.string "bank_type"
    t.string "image"
    t.string "image_id"
    t.string "location"
    t.string "postal_address"
    t.integer "campaign_ids", default: [], array: true
    t.string "state"
    t.string "country"
    t.string "city"
    t.string "category"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "integrations", "shops"
  add_foreign_key "liked_users_store_customers", "store_customers"
  add_foreign_key "liked_users_store_customers", "users"
  add_foreign_key "orders", "shops"
  add_foreign_key "orders", "users"
  add_foreign_key "store_customers", "shops"
end
