class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_shopify_client, only: %i[charities accept_widget]

  def customer_data_request
    if from_shopify(request)
      head :ok
    else
      head :unauthorized
    end
  end

  def shop_redact
    if from_shopify(request)
      puts "SUCCESS"
      head :ok
    else
      head :unauthorized
    end
  end

  def customer_redact
    if from_shopify(request)
      head :ok
    else
      head :unauthorized
    end
  end

  def orders_create
    if from_shopify(request)
      shopify_domain = request.env["HTTP_X_SHOPIFY_SHOP_DOMAIN"]
      OrderCreateJob.perform_later(shop_domain: shopify_domain, order_params: params.permit!)
      head :ok
    else
      head :unauthorized
    end
  end


  def orders_paid
    if from_shopify(request)
      shopify_domain = request.env["HTTP_X_SHOPIFY_SHOP_DOMAIN"]
      # OrdersPaidJob.perform_later(shop_domain: shopify_domain, webhook: params.permit!)
      head :ok
    else
      head :unauthorized
    end
  end

  def charities
    charities = User.charity.approved
    campaign = ""
    return render json: charities.as_json(except: [:image]) unless Campaign.active.exists?

    product_id = params[:product_id]
    collections = fetch_product_collections(product_id)

    collections&.each do |collection|
      campaign = Campaign.find_by_category_id(collection.id)
      if campaign&.active
        charities = campaign.users
        campaign = campaign.id
        break
      end
    end
    render json: { charities: charities.as_json(except: [:image]), campaign: campaign }
  end

  def accept_widget
    accept_widget_ack = false
    return render json: { notice: accept_widget_ack } unless Campaign.active.exists?

    product_id = params[:product_id]
    collections = fetch_product_collections(product_id)

    accept_widget_ack = collections&.any? { |collection| Campaign.active.exists?(category_id: collection.id) }

    render json: { notice: accept_widget_ack }
  end

  def featured_charities
    email = params[:email]
    shop_domain = extract_shop_domain(params[:store_url])
    shop = Shop.find_by(shopify_domain: shop_domain)
    puts shop

    if shop.present?
      featured_charities = fetch_featured_charities(email, shop)
      render json: featured_charities.as_json(except: [:image])
    else
      render json: { error: 'Shop not found' }, status: :not_found
    end
  end


  private

  def from_shopify(request)
    header_hmac = request.env["HTTP_X_SHOPIFY_HMAC_SHA256"]
    request.body.rewind
    data = request.body.read
    WebhookHelper.verify_webhook(data, header_hmac)
  end


  def extract_shop_domain(store_url)
    return unless store_url.present?
  
    URI.parse(store_url).host.sub(/^www\./, '')
  rescue URI::InvalidURIError
    nil
  end
  
  def fetch_featured_charities(email, shop)
    charities = User.approved.where(user_type: User.user_types[:charity]).last(3)
    return charities unless email.present?
    puts email
    customer = StoreCustomer.find_or_create_by(email: email, shop_id: shop.id)
    customer.featured_charities
  end


  def set_shopify_client
    Shop.find(34).with_shopify_session do
      @client = ShopifyAPI::GraphQL.client
    end
  end

  def fetch_product_collections(product_id)
    Shop.find(34).with_shopify_session do
      begin
        response = ShopifyService.new.get_collection_name(@client, product_id)
        if response.data&.product
          return response.data.product.collections.nodes
        else
          Rails.logger.error "Shopify API Error: #{response.errors || 'No collections found'}"
        end
      rescue StandardError => e
        Rails.logger.error "Shopify API request failed: #{e.message}"
      end
    end
    nil
  end
end
