class ExternalIdentity < ApplicationRecord
  belongs_to :person

  validates :source, :external_id, presence: true
  validates :source, uniqueness: { scope: :external_id }
end
