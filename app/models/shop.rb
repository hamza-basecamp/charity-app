class Shop < ApplicationRecord
  has_many :orders
  has_one :integration
  has_many :store_customers

  def integration
    Integration.find_by(shop_id: id)
  end

  def activate_shopify_session
    return false unless integration.present?

    session = ShopifyAPI::Session.new(domain: integration.unique_id, api_version: ENV['SHOPIFY_API_VERSION'], token: integration.token)
    ShopifyAPI::Base.activate_session(session)
  end

  def with_shopify_session
    activate_shopify_session
    yield
  end
end
