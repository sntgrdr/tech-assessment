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
      orders_relation: final_scope.recent,
      stats: build_stats(global_filtered_scope, final_scope)
    }
  end

  private

  def apply_global_filters(scope)
    scope = scope.includes(:person)

    scope = scope.by_number(@params[:number]) if @params[:number].present?

    scope = scope.joins(:person).where("people.email ILIKE ?", "%#{@params[:email]}%") if @params[:email].present?

    if @params[:from_date].present? || @params[:to_date].present?
      start_d = @params[:from_date].present? ? @params[:from_date].to_date.beginning_of_day : Time.at(0)
      end_d = @params[:to_date].present? ? @params[:to_date].to_date.end_of_day : Time.current
      scope = scope.by_date_range(start_d, end_d)
    end

    scope
  end

  def apply_status_filter(scope)
    return scope if @params[:status].blank? || @params[:status] == "all"

    scope.by_status(@params[:status])
  end

  def build_stats(global_scope, final_scope)
    {
      total_orders: global_scope.count,
      pending_orders: global_scope.by_status("pending").count,
      confirmed_orders: global_scope.by_status("confirmed").count,
      processing_orders: global_scope.by_status("processing").count,
      shipped_orders: global_scope.by_status("shipped").count,
      delivered_orders: global_scope.by_status("delivered").count,

      total_revenue: final_scope.sum(:total_amount).to_f.round(2),
      average_order_value: final_scope.average(:total_amount).to_f.round(2)
    }
  end
end
