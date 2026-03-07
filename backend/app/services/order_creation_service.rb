class OrderCreationService
  class InvalidOrderError < StandardError; end

  def self.create_order(person, order_params)
    order = person.orders.build(order_params)

    if order.save
      order
    else
      raise InvalidOrderError, order.errors.full_messages.join(", ")
    end
  end
end
