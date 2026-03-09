class Person < ApplicationRecord
  has_many :external_identities, dependent: :destroy

  validates :email, :first_name, :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { case_sensitive: false }
end
