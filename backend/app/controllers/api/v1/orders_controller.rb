class Api::V1::OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :update, :destroy ]

  # GET /api/v1/orders
  def index
    debugger
    @orders = Order.all.includes(:person)
    render json: @orders.as_json(include: :person)
  end

  # GET /api/v1/orders/:id
  def show
    render json: @order.as_json(include: :person)
  end

  # POST /api/v1/orders
  def create
    @order = Order.new(order_params)

    if @order.save
      render json: @order.as_json(include: :person), status: :created
    else
      render json: { errors: @order.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/orders/:id
  def update
    if @order.update(order_params)
      render json: @order.as_json(include: :person)
    else
      render json: { errors: @order.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/orders/:id
  def destroy
    @order.destroy
    head :no_content
  end

  # GET /api/v1/orders/stats
  def stats
    stats = {
      total_orders: Order.count,
      orders_today: Order.where(created_at: Date.current.all_day).count,
      orders_this_month: Order.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count,
      pending_orders: Order.where(status: "pending").count,
      confirmed_orders: Order.where(status: "confirmed").count,
      delivered_orders: Order.where(status: "delivered").count
    }

    render json: stats
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:person_id, :status, :total_amount, :notes, :order_date)
  end
end
