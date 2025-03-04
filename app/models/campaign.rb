class Campaign < ApplicationRecord
  scope :active, -> { where(active: true) }
  before_destroy :remove_from_users


  def toggle_approval
  update(active: !active)
  end
  
  def users
    User.where("? = ANY(campaign_ids)", id) # For PostgreSQL array column
  end
  
  private

  def remove_from_users
    User.find_each do |user|
      user.update(campaign_ids: user.campaign_ids - [id]) if user.campaign_ids.include?(id)
    end
  end
end
