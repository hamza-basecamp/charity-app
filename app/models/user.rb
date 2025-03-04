class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_and_belongs_to_many :store_customers, join_table: 'liked_users_store_customers', foreign_key: 'user_id', association_foreign_key: 'store_customer_id'
  has_many :orders

  scope :approved, -> { where(approved: true) }
  scope :without_campaign, -> { where(campaign_id: nil) }
  enum user_type: { admin: 'admin', charity: 'charity' }
  has_one_attached :image  # This links the image to Active Storage


  def toggle_approval
    update(approved: !approved)
  end

  def campaigns
    Campaign.where(id: campaign_ids)
  end
  
  def add_campaign(campaign)
    update(campaign_ids: campaign_ids.push(campaign.id).uniq)
  end

  def remove_campaign(campaign)
    update(campaign_ids: campaign_ids - [campaign.id])
  end
end
