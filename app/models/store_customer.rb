class StoreCustomer < ApplicationRecord
  belongs_to :shop

  has_and_belongs_to_many :featured_charities, class_name: 'User', join_table: 'liked_users_store_customers', foreign_key: 'store_customer_id', association_foreign_key: 'user_id'
  
  validate :limit_featured_charities
  after_create :like_first_three_users

  private
  
  def like_first_three_users
    # Find the first 3 users (order them as needed, here it's by ID)
    users_to_like = User.approved.where(user_type: User.user_types[:charity]).limit(3)

    # Add them to the featured_charities association
    self.featured_charities << users_to_like
  end

  def limit_featured_charities
    if featured_charities.count > 3
      errors.add(:featured_charities, "cannot exceed 3 users.")
    end
  end
end
