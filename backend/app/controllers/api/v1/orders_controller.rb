class Api::V1::OrdersController < ApplicationController
  include Authenticatable

  before_action :set_order, only: [ :show, :update, :destroy ]

  # GET /api/v1/orders
  def index
    @orders = current_person.orders.recent.includes(:person)
    render json: @orders.as_json(include: :person)
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
    @order = current_person.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  end

  def order_creation_params
    params.require(:order).permit(:total_amount, :notes, :order_date)
  end

  def order_update_params
    params.require(:order).permit(:status, :total_amount, :notes, :order_date)
  end
end
