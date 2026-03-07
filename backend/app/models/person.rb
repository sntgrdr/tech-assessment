class Person < ApplicationRecord
  has_secure_password

  has_many :orders, dependent: :destroy

  enum :role, { customer: 0, admin: 1 }.freeze, default: :customer

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :phone, length: { maximum: 20 }
  validates :company, length: { maximum: 100 }
end
