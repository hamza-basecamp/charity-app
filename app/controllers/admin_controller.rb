class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :set_charity, only: %i[approve disapprove update_charity]
  before_action :set_campaign, only: %i[campaign_active campign_deactive update_campaign delete_campaign]

  def index
    redirect_to new_user_registration_path unless user_signed_in?
    redirect_to admin_orders_path
  end

  def orders
    @order = Order.all
    @campaign = Campaign.all
  end

  def charities
    @charities =  User.charity
  end

  def update_charity
    if @charity.update(commission_type: params[:commission_type], commission_rate: params[:commission_rate])
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("charity_#{@charity.id}", partial: "admin/charity_row", locals: { charity: @charity }) }
        format.html { redirect_to admin_charities_path, notice: "Charity updated successfully" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(:edit_charity, partial: "admin/edit_charity_form", locals: { charity: @charity }) }
        format.html { render :edit }
      end
    end
  end

  def approve
    @charity.toggle_approval  # Toggle the approved status
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("charity_#{@charity.id}", partial: "admin/charity_row", locals: { charity: @charity }) }
      format.html { redirect_to admin_dashboard_path, notice: "Charity approved successfully." }
    end
  end

  def disapprove
    @charity.toggle_approval
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("charity_#{@charity.id}", partial: "admin/charity_row", locals: { charity: @charity }) }
      format.html { redirect_to admin_dashboard_path, notice: "Charity disapproved successfully." }
    end
  end

  def campaign
    @collection_info = [] 
    @charities = User.approved.pluck(:company_name, :id)
    Shop.find(1).with_shopify_session do
      client = ShopifyAPI::GraphQL.client
      res = ShopifyService.new.get_collections(client)
      if res.data.collections
        res.data.collections.edges.each do |edge|
          unless Campaign.exists?(category_id: edge.node.id, name: edge.node.title)
            @collection_info << { id: edge.node.id, title: edge.node.title }
          end
        end
      else
        puts "Error: #{res.errors[:data]}"
      end
    end
  end

  def create_campaign
    user_ids = params[:user_ids].first.split(',').map(&:to_i) rescue []
    campaign = Campaign.new(
      name: params[:campaign_title],
      category_id: params[:campaign_id],
      campaign_percentage: params[:campaign_percentage],
      active: true,
    )
    if campaign.save
      update_commission_rate(campaign,user_ids)
      respond_to do |format|
        format.html { redirect_to admin_campaign_path, notice: 'Campaign created successfully.' }
      end
    else
      render json: { success: false, errors: campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def campaign_active
    @campaign.toggle_approval
    respond_to do |format|
      format.html { redirect_to admin_orders_path, notice: "Campaign approved successfully." }
    end
  end

  def campign_deactive
    @campaign.toggle_approval
    respond_to do |format|
      format.html { redirect_to admin_orders_path, notice: "Campaign disapproved successfully." }
    end
  end

  def update_campaign
    if @campaign.update(campaign_percentage:  params[:commission_rate])
      update_commission_rate(@campaign, @campaign.users.pluck(:id))
      respond_to do |format|
        format.html { redirect_to admin_orders_path, notice: "Campaign updated successfully" }
      end
    else
      respond_to do |format|
        format.html { render :edit }
      end
    end
  end

  def delete_campaign
    if @campaign.destroy
      respond_to do |format|
        format.html { redirect_to admin_orders_path, notice: "Campaign Deleted successfully" }
      end
    end
  end

  private

  def authenticate_user!
    super
  end

  def check_admin
    redirect_to root_path, alert: "You are not authorized to view this page." unless current_user.admin?
  end

  def set_charity
    @charity = User.find(params[:id])
  end

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def update_commission_rate(campaign, user_ids)
    User.where(id: user_ids).find_each do |user|
      user.update(
        campaign_ids: (user.campaign_ids << campaign.id).uniq,  # Add campaign ID while avoiding duplicates
        commission_rate: campaign.campaign_percentage
      )
    end
  end
  
end
