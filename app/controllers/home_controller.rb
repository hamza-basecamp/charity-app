class HomeController < ApplicationController
  before_action :authenticate_user!  
  before_action :check_charity

  def index
    redirect_to new_user_registration_path unless user_signed_in?
  end

  def charity
    redirect_to new_user_registration_path unless user_signed_in?
    @order = current_user.orders
  end

  def profile 
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to charity_profile_path, notice: 'Profile updated successfully!'
    else
      render :profile, status: :unprocessable_entity
    end
  end
  private

  def user_params
    params.require(:user).permit(:company_name, :ein_number, :tax_number, :account_number, :location, :postal_address, :description, :image, :category, :city, :state, :country)
  end

  def check_charity
    redirect_to admin_dashboard_path, alert: "You are not authorized to view this page." unless current_user.charity?
  end
end
