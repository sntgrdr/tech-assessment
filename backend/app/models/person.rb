class Person < ApplicationRecord
  has_secure_password

  has_many :orders, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :phone, length: { maximum: 20 }
  validates :company, length: { maximum: 100 }

  # Helper methods
  def orders_count
    orders.count
  end

  def recent_orders(limit = 5)
    orders.recent.limit(limit)
  end

  def orders_by_status(status)
    orders.by_status(status)
  end
end
