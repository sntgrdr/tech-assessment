class OrderIndexService
  def initialize(user, params)
    @user = user
    @params = params
  end

  def call
    orders = filtered_orders

    # We calculate stats before pagination to include the whole filtered set
    stats = calculate_stats(orders)

    # We use a controller context for pagy or handle it here
    # Since pagy usually needs the controller context, we return the relation
    {
      orders_relation: orders.order(created_at: :desc),
      stats: stats
    }
  end

  private

  def filtered_orders
    scope = @user.admin? ? Order.all : @user.orders
    scope = scope.includes(:person)

    scope = scope.where(status: @params[:status]) if @params[:status].present? && @params[:status] != 'all'
    scope = scope.joins(:person).where('people.email ILIKE ?', "%#{@params[:email]}%") if @params[:email].present?
    scope = scope.where('orders.created_at >= ?', @params[:from_date].to_date.beginning_of_day) if @params[:from_date].present?
    scope = scope.where('orders.created_at <= ?', @params[:to_date].to_date.end_of_day) if @params[:to_date].present?

    scope
  end

  def calculate_stats(scope)
    {
      total_orders: scope.count,
      total_revenue: scope.sum(:total_amount),
      pending_orders: scope.where(status: 'pending').count,
      confirmed_orders: scope.where(status: 'confirmed').count,
      processing_orders: scope.where(status: 'processing').count,
      shipped_orders: scope.where(status: 'shipped').count,
      delivered_orders: scope.where(status: 'delivered').count,
      average_order_value: scope.average(:total_amount).to_f.round(2)
    }
  end
end
