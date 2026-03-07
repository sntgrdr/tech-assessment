class OrderCreationService
  class InvalidOrderError < StandardError; end

  def self.create_order(person, order_params)
    order = person.orders.build(order_params)

    validate_order(order)

    if order.save
      # Email notification hook (for future implementation)
      # OrderNotificationService.new(order).send_confirmation

      order
    else
      raise InvalidOrderError, order.errors.full_messages.join(", ")
    end
  end

  private

  def self.validate_order(order)
    # Add any custom business validations here
    # For example: minimum order amount, business rules, etc.

    unless order.total_amount&.positive?
      raise InvalidOrderError, "Total amount must be greater than 0"
    end
  end
end
