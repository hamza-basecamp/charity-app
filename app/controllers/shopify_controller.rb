class ShopifyController < ActionController::Base
  before_action :throttle_requests, only: [:auth_callback]

  def authenticate
    scopes = 'read_order_edits,write_order_edits,read_orders,write_orders,read_products'
    redirect_uri = "#{ENV['BASE_URL']}/auth/shopify/callback"

    install_url = "https://#{params[:shop]}/admin/oauth/authorize?client_id=#{ENV['SHOPIFY_API_KEY']}&scope=#{scopes}&redirect_uri=#{redirect_uri}"
    redirect_to install_url, allow_other_host: true
  end


  def auth_callback
    temp_token, myshopify_domain = params[:code], params[:shop]
    begin
        shop = Shop.find_by shopify_domain: myshopify_domain
        if shop.blank?
          shop = Shop.create!(shopify_domain: myshopify_domain, shopify_token: temp_token)
        end
        integration = Integration.find_or_initialize_by(unique_id: myshopify_domain, auth_service: 'shopify')
        if integration.new_record?
          integration.update!(temp_token: temp_token, shop_id: shop.id)
        else
          integration.update!(temp_token: temp_token)
        end
        res = ShopifyService.new.generate_token(myshopify_domain, ENV['SHOPIFY_API_KEY'], ENV['SHOPIFY_API_SECRET'], temp_token)
        res = JSON.parse(res.body)
        integration.update(token: res['access_token'])
        create_webhooks(shop)
        redirect_to admin_dashboard_path
    rescue => e
      p "::::::::::::::::: error on reterving  :::::::::::::::::::::::: #{e}"
      render json: { "status" => "error", "message" => "Invalid credentials." }, status:404
    end
  end

  private

  def create_webhooks(shop)
    shop.with_shopify_session do
      fields = %w[id name financial_status order_number total_price total_line_items_price total_discounts created_at updated_at line_items]
      shopify_webhook('orders/create', 'orders_create', fields)
      shopify_webhook('orders/paid', 'orders_paid', [])
    end
  rescue => e
    p e.inspect.to_s
  end

  def shopify_webhook(topic, adrdress, fields)
    ShopifyAPI::Webhook.create(
      format: 'json',
      topic: topic,
      address: "#{ENV['BASE_URL']}/webhook/#{adrdress}",
      fields: fields
    )
  end

  def throttle_requests
    oauth_state = params[:state]
    if Rails.cache.read(oauth_state)
      render status: :too_many_requests, json: { error: "Too many requests. Please try again later." }
    end
  end
end
