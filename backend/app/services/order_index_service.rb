class OrderIndexService
  def initialize(user, params)
    @user = user
    @params = params
  end

  def call
    base_scope = @user.admin? ? Order.all : @user.orders

    global_filtered_scope = apply_global_filters(base_scope)

    final_scope = apply_status_filter(global_filtered_scope)

    {
      orders_relation: final_scope.order(created_at: :desc),
      stats: build_stats(global_filtered_scope, final_scope)
    }
  end

  private

  def apply_global_filters(scope)
    scope = scope.includes(:person)
    scope = scope.joins(:person).where("people.email ILIKE ?", "%#{@params[:email]}%") if @params[:email].present?
    scope = scope.where("orders.created_at >= ?", @params[:from_date].to_date.beginning_of_day) if @params[:from_date].present?
    scope = scope.where("orders.created_at <= ?", @params[:to_date].to_date.end_of_day) if @params[:to_date].present?
    scope
  end

  def apply_status_filter(scope)
    if @params[:status].present? && @params[:status] != "all"
      scope = scope.where(status: @params[:status])
    end
    scope
  end

  def build_stats(global_scope, final_scope)
    {
      # Estas cards respetan Email y Fecha, pero NO el clic en el status
      total_orders: global_scope.count,
      pending_orders: global_scope.where(status: "pending").count,
      confirmed_orders: global_scope.where(status: "confirmed").count,
      processing_orders: global_scope.where(status: "processing").count,
      shipped_orders: global_scope.where(status: "shipped").count,
      delivered_orders: global_scope.where(status: "delivered").count,

      # Estas cards respetan TODO, incluido el clic en la card de status
      total_revenue: final_scope.sum(:total_amount).to_f.round(2),
      average_order_value: final_scope.average(:total_amount).to_f.round(2)
    }
  end
end
