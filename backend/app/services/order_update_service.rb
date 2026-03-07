class OrderUpdateService
  class InvalidOrderError < StandardError; end

  def self.update_order(order, order_params)
    validate_status_transition(order, order_params[:status]) if order_params[:status]

    if order.update(order_params)
      order
    else
      raise InvalidOrderError, order.errors.full_messages.join(", ")
    end
  end

  private

  def self.validate_status_transition(order, new_status)
    return unless new_status && order.status != new_status

    valid_transitions = {
      "pending" => [ "confirmed", "cancelled" ],
      "confirmed" => [ "processing", "cancelled" ],
      "processing" => [ "shipped", "cancelled" ],
      "shipped" => [ "delivered" ],
      "delivered" => [],
      "cancelled" => []
    }

    allowed_statuses = valid_transitions[order.status] || []

    unless allowed_statuses.include?(new_status)
      raise InvalidOrderError, "Invalid status transition from #{order.status} to #{new_status}"
    end
  end
end
