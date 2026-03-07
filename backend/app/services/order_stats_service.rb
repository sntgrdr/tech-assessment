class OrderStatsService
  def self.get_person_stats(person)
    orders = person.orders

    stats_payload(orders)
  end

  private

  def self.stats_payload(orders)
    {
      total_orders: orders.count,
      orders_today: orders_today_count(orders),
      orders_this_month: orders_this_month_count(orders),
      pending_orders: orders.where(status: "pending").count,
      confirmed_orders: orders.where(status: "confirmed").count,
      processing_orders: orders.where(status: "processing").count,
      shipped_orders: orders.where(status: "shipped").count,
      delivered_orders: orders.where(status: "delivered").count,
      cancelled_orders: orders.where(status: "cancelled").count,
      total_revenue: total_revenue(orders),
      average_order_value: average_order_value(orders)
    }
  end

  def self.orders_today_count(orders)
    orders.where(created_at: Date.current.all_day).count
  end

  def self.orders_this_month_count(orders)
    orders.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count
  end

  def self.total_revenue(orders)
    orders.where(status: [ "confirmed", "processing", "shipped", "delivered" ])
          .sum(:total_amount)
  end

  def self.average_order_value(orders)
    delivered_orders = orders.where(status: "delivered")
    return 0 if delivered_orders.empty?

    delivered_orders.average(:total_amount).to_f.round(2)
  end
end
