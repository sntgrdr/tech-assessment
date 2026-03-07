require 'rails_helper'

RSpec.describe "Orders API", type: :request do
  let!(:person) { create(:person, password: 'password123') }
  let!(:order1) { create(:order, person: person, status: 'pending', total_amount: 100.00) }
  let!(:order2) { create(:order, person: person, status: 'confirmed', total_amount: 200.00) }
  let!(:other_person) { create(:person, password: 'password123') }
  let!(:other_order) { create(:order, person: other_person, status: 'pending', total_amount: 50.00) }

  let(:auth_headers) do
    token = AuthService.generate_token(person.id)
    { "Authorization" => "Bearer #{token}" }
  end

  describe "GET /api/v1/orders" do
    it "returns current user's orders only" do
      get "/api/v1/orders", headers: auth_headers, as: :json

      expect(response).to have_http_status(:ok)
      orders = JSON.parse(response.body)
      expect(orders.size).to eq(2)
      expect(orders.map { |o| o['id'] }).to contain_exactly(order1.id, order2.id)
    end

    it "returns unauthorized without authentication" do
      get "/api/v1/orders", as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/orders/:id" do
    it "returns current user's order" do
      get "/api/v1/orders/#{order1.id}", headers: auth_headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(order1.id)
    end

    it "returns not found for other user's order" do
      get "/api/v1/orders/#{other_order.id}", headers: auth_headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/orders" do
    it "creates a new order for current user" do
      order_params = {
        order: {
          status: 'pending',
          total_amount: 150.00,
          notes: 'Test order'
        }
      }

      post "/api/v1/orders", params: order_params, headers: auth_headers, as: :json

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq('pending')
      expect(json_response['person']['id']).to eq(person.id)
    end

    it "returns errors for invalid order" do
      order_params = {
        order: {
          status: 'pending',
          total_amount: -10
        }
      }

      post "/api/v1/orders", params: order_params, headers: auth_headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end
  end

  describe "GET /api/v1/orders/stats" do
    it "returns current user's statistics" do
      get "/api/v1/orders/stats", headers: auth_headers, as: :json

      expect(response).to have_http_status(:ok)
      stats = JSON.parse(response.body)
      expect(stats['total_orders']).to eq(2)
      expect(stats['pending_orders']).to eq(1)
      expect(stats['confirmed_orders']).to eq(1)
    end
  end

  describe "PUT /api/v1/orders/:id" do
    it "updates current user's order" do
      update_params = {
        order: {
          status: 'confirmed',
          notes: 'Updated notes'
        }
      }

      put "/api/v1/orders/#{order1.id}", params: update_params, headers: auth_headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('confirmed')
    end

    it "returns not found for other user's order" do
      update_params = {
        order: {
          status: 'confirmed'
        }
      }

      put "/api/v1/orders/#{other_order.id}", params: update_params, headers: auth_headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/orders/:id" do
    it "deletes current user's order" do
      delete "/api/v1/orders/#{order1.id}", headers: auth_headers, as: :json

      expect(response).to have_http_status(:no_content)
      expect(Order.find_by(id: order1.id)).to be_nil
    end

    it "returns not found for other user's order" do
      delete "/api/v1/orders/#{other_order.id}", headers: auth_headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
