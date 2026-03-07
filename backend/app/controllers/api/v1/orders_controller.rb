class Api::V1::OrdersController < ApplicationController
  include Authenticatable

  before_action :set_order, only: [ :show, :update, :destroy ]
  before_action :authorize_admin!, only: [ :update, :destroy ]

  # GET /api/v1/orders
  def index
    service_result = OrderIndexService.new(current_person, index_params).call

    @pagy, @orders = pagy(service_result[:orders_relation], items: 8, page: index_params[:page])

    render json: {
      orders: @orders.as_json(include: { person: { only: [ :id, :email ] } }),
      pagination: pagy_metadata(@pagy),
      stats: service_result[:stats]
    }
  end

  # GET /api/v1/orders/:id
  def show
    render json: @order.as_json(include: :person)
  end

  # POST /api/v1/orders
  def create
    @order = OrderCreationService.create_order(current_person, order_creation_params)
    render json: @order.as_json(include: :person), status: :created
  rescue OrderCreationService::InvalidOrderError => e
    render json: { errors: e.message }, status: :unprocessable_entity
  end

  # PATCH/PUT /api/v1/orders/:id
  def update
    @order = OrderUpdateService.update_order(@order, order_update_params)
    render json: @order.as_json(include: :person)
  rescue OrderUpdateService::InvalidOrderError => e
    render json: { errors: e.message }, status: :unprocessable_entity
  end

  # GET /api/v1/orders/stats
  def stats
    stats = OrderStatsService.get_person_stats(current_person)
    render json: stats
  end

  # DELETE /api/v1/orders/:id
  def destroy
    @order.destroy
    head :no_content
  end

  private

  def set_order
    @order = if current_person.admin?
               Order.find_by(id: params[:id])
    else
               current_person.orders.find_by(id: params[:id])
    end
    render json: { error: "Order not found" }, status: :not_found unless @order
  end

  def order_creation_params
    params.require(:order).permit(:total_amount, :notes, :order_date)
  end

  def order_update_params
    params.require(:order).permit(:status, :total_amount, :notes, :order_date)
  end

  def authorize_admin!
    unless current_person.admin?
      render json: { error: "Not authorized. Admins only." }, status: :forbidden
    end
  end

  def index_params
    params.permit(:status, :email, :from_date, :to_date, :page)
  end
end
