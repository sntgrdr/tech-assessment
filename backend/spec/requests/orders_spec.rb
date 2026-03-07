require 'rails_helper'

RSpec.describe "Orders API", type: :request do
  let!(:person) { create(:person) }
  let!(:order1) { create(:order, person: person, status: 'pending', total_amount: 100.00) }
  let!(:order2) { create(:order, person: person, status: 'confirmed', total_amount: 200.00) }

  describe "GET /api/v1/orders" do
    it "returns all orders" do
      get "/api/v1/orders", as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe "GET /api/v1/orders/:id" do
    it "returns a specific order" do
      get "/api/v1/orders/#{order1.id}", as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(order1.id)
    end
  end

  describe "POST /api/v1/orders" do
    it "creates a new order" do
      order_params = {
        order: {
          person_id: person.id,
          status: 'pending',
          total_amount: 150.00,
          notes: 'Test order'
        }
      }

      post "/api/v1/orders", params: order_params, as: :json

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['status']).to eq('pending')
    end

    it "returns errors for invalid order" do
      order_params = {
        order: {
          person_id: nil,
          status: 'pending',
          total_amount: -10
        }
      }

      post "/api/v1/orders", params: order_params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end
  end

  describe "GET /api/v1/orders/stats" do
    it "returns order statistics" do
      get "/api/v1/orders/stats", as: :json

      expect(response).to have_http_status(:ok)
      stats = JSON.parse(response.body)
      expect(stats).to have_key('total_orders')
      expect(stats).to have_key('orders_today')
      expect(stats).to have_key('orders_this_month')
      expect(stats).to have_key('pending_orders')
      expect(stats).to have_key('confirmed_orders')
      expect(stats).to have_key('delivered_orders')
    end
  end

  describe "PUT /api/v1/orders/:id" do
    it "updates an order" do
      update_params = {
        order: {
          status: 'confirmed',
          notes: 'Updated notes'
        }
      }

      put "/api/v1/orders/#{order1.id}", params: update_params, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('confirmed')
    end
  end

  describe "DELETE /api/v1/orders/:id" do
    it "deletes an order" do
      delete "/api/v1/orders/#{order1.id}", as: :json

      expect(response).to have_http_status(:no_content)
      expect(Order.find_by(id: order1.id)).to be_nil
    end
  end
end
