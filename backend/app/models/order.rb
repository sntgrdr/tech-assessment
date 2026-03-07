class Order < ApplicationRecord
  belongs_to :person

  enum status: {
    pending: "pending",
    confirmed: "confirmed",
    processing: "processing",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  # Validations
  validates :person, presence: true
  validates :number, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :order_date, presence: true

  # Callbacks
  before_validation :set_order_date, on: :create
  before_validation :generate_order_number, on: :create

  after_create_commit :send_confirmation_email

  # Scopes for common queries
  scope :by_customer, ->(person_id) { where(person_id: person_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_date_range, ->(start_date, end_date) { where(order_date: start_date..end_date) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_number, ->(number) { where(number: number) }


  private

  def set_order_date
    self.order_date ||= Date.current
  end

  def generate_order_number
    self.number ||= "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
  end

  def send_confirmation_email
    OrderMailer.confirmation_email(self).deliver_later
  end
end
