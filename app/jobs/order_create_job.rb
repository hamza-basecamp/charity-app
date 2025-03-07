class OrderCreateJob < ApplicationJob
  queue_as :default

  def perform(shop_domain:, order_params:)
    return if order_params['line_items'].empty?

    shop = Shop.find_by(shopify_domain: shop_domain)
    return unless shop

    order_params['line_items'].each do |line_item|
      process_line_item(line_item, order_params, shop)
    end
  end

  private

  def process_line_item(line_item, order_params, shop)
    charity_id, campaign = extract_charity_and_campaign(line_item['properties'])
    return unless charity_id && campaign

    campaign = Campaign.find_by(id: campaign.to_i)
    return unless campaign

    order = create_order(line_item, order_params, shop, charity_id, campaign)
    return unless order.save

    log_order_details(charity_id, line_item['quantity'], order.charity_price, campaign)
  rescue ActiveRecord::RecordNotFound => e
    logger.debug("Record not found: #{e.message}")
  rescue => e
    logger.debug("Error processing line item: #{e.message}")
  end

  def extract_charity_and_campaign(properties)
    line_property = properties&.find { |prop| prop['name'] == 'Charity Id' }
    return nil unless line_property

    line_property['value'].split('.')
  end

  def create_order(line_item, order_params, shop, charity_id, campaign)
    quantity = line_item['quantity']
    total_price = line_item['price'].to_f * quantity
    charity_price = calculate_charity_price(campaign, total_price)

    Order.new(
      charity_price: charity_price,
      total_line_items_price: total_price,
      charity_percentage: campaign.campaign_percentage.to_i,
      user_id: charity_id.to_i,
      financial_status: order_params['financial_status'],
      order_number: order_params['order_number'],
      shopify_order_id: order_params['id'],
      shop_id: shop.id,
      campaign_name: campaign.name
    )
  end

  def calculate_charity_price(campaign, total_price)
    return nil unless campaign.campaign_percentage

    (campaign.campaign_percentage.to_f / 100) * total_price
  end

  def log_order_details(charity_id, quantity, charity_price, campaign)
    logger.info "Charity ID: #{charity_id}, Quantity: #{quantity}, Total Price: #{charity_price}"
    logger.info "Campaign Name: #{campaign.name}, Quantity: #{quantity}, Total Price: #{charity_price}"
  end
end
