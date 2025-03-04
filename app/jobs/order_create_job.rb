class OrderCreateJob < ApplicationJob
  queue_as :default
  def perform(shop_domain:, order_params:)
    return if order_params['line_items'].empty?
    order_params['line_items'].each do |li|
      line_property = li['properties']&.find { |prop| prop['name'] == 'Charity Id' }['value']
      charity_id, campaign = line_property.split(".")
      financial_status = order_params['financial_status']
      order_number = order_params['order_number']
      shopify_order_id = order_params['id']
      shop = Shop.find_by(shopify_domain: shop_domain)
      
      if charity_id && campaign
        # charity = User.find(charity_id.to_i) 
        # percentage = charity.commission_rate if charity.commission_type === "percentage"
        # quantity = li['quantity']  
        # total_price = li['price'].to_f * quantity
        # charity_price = (percentage.to_f / 100) * total_price if percentage.present?
        campaign = Campaign.find(campaign.to_i) 
        percentage = campaign.campaign_percentage
        quantity = li['quantity']  
        total_price = li['price'].to_f * quantity
        charity_price = (percentage.to_f / 100) * total_price if percentage.present?
        order = Order.create(charity_price: charity_price,
                    total_line_items_price: total_price,
                    charity_percentage: percentage.to_i,
                    user_id: charity_id.to_i,
                    financial_status: financial_status,
                    order_number: order_number,
                    shopify_order_id: shopify_order_id,
                    shop_id: shop.id,
                    campaign_name: campaign.name
                    )
        if (order.save)
        puts "Charity ID: #{charity_id}, Quantity: #{quantity}, Total Price: #{charity_price}"
        puts "Campaign Name: #{campaign.name}, Quantity: #{quantity}, Total Price: #{charity_price}"
        else
          logger.debug "Error #{order.errors.full_messages}"
          return
        end
      end  
     end
  end
end