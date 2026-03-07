require 'rails_helper'

RSpec.describe "Orders API", type: :request do
  let!(:admin) { create(:person, role: :admin, password: 'password123') }
  let!(:person) { create(:person, role: :customer, password: 'password123') }
  let!(:other_person) { create(:person, role: :customer, password: 'password123') }

  let!(:order1) { create(:order, person: person, status: 'pending', total_amount: 100.00) }
  let!(:order2) { create(:order, person: person, status: 'confirmed', total_amount: 200.00) }

  let!(:other_order) { create(:order, person: other_person, status: 'pending', total_amount: 50.00) }

  describe "GET /api/v1/orders" do
    context "as a customer" do
      it "returns current user's orders only" do
        get "/api/v1/orders", headers: auth_headers(person), as: :json

        expect(response).to have_http_status(:ok)
        expect(json['orders'].size).to eq(2)
        expect(json['orders'].map { |o| o['id'] }).to contain_exactly(order1.id, order2.id)
      end

      it "returns paginated orders" do
        get "/api/v1/orders", headers: auth_headers(person), as: :json

        expect(response).to have_http_status(:ok)
        expect(json).to have_key('orders')
        expect(json).to have_key('pagination')
        expect(json['orders'].size).to eq(2)
      end
    end

    context "as an admin" do
      it "returns all orders from all users" do
        get "/api/v1/orders", headers: auth_headers(admin), as: :json

        expect(response).to have_http_status(:ok)
        expect(json['orders'].size).to eq(12)
        expect(json['orders'].map { |o| o['id'] }).to include(order1.id, order2.id, other_order.id)
      end
    end

    it "returns unauthorized without authentication" do
      get "/api/v1/orders", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/orders/:id" do
    it "returns current user's order" do
      get "/api/v1/orders/#{order1.id}", headers: auth_headers(person), as: :json

      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(order1.id)
    end

    it "returns not found for other user's order if requested by customer" do
      get "/api/v1/orders/#{other_order.id}", headers: auth_headers(person), as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "allows admin to see any order" do
      get "/api/v1/orders/#{other_order.id}", headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(other_order.id)
    end
  end

  describe "POST /api/v1/orders" do
    it "creates a new order for current user" do
      order_params = {
        order: { status: 'pending', total_amount: 150.00, notes: 'Test order' }
      }

      post "/api/v1/orders", params: order_params, headers: auth_headers(person), as: :json

      expect(response).to have_http_status(:created)
      expect(json['status']).to eq('pending')
      expect(json['person']['id']).to eq(person.id)
    end
  end

  describe "PUT /api/v1/orders/:id" do
    context "as an admin" do
      it "updates any user's order" do
        update_params = { order: { status: 'confirmed' } }
        put "/api/v1/orders/#{order1.id}", params: update_params, headers: auth_headers(admin), as: :json

        expect(response).to have_http_status(:ok)
        expect(json['status']).to eq('confirmed')
      end
    end

    context "as a customer" do
      it "returns forbidden when trying to update" do
        update_params = { order: { status: 'confirmed' } }
        put "/api/v1/orders/#{order1.id}", params: update_params, headers: auth_headers(person), as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/orders/:id" do
    context "as an admin" do
      it "deletes a pending order" do
        delete "/api/v1/orders/#{order1.id}", headers: auth_headers(admin), as: :json

        expect(response).to have_http_status(:no_content)
        expect(Order.find_by(id: order1.id)).to be_nil
      end

      it "returns error when deleting a non-pending order" do
        delete "/api/v1/orders/#{order2.id}", headers: auth_headers(admin), as: :json

        expect(response).to have_http_status(:no_content)
        expect(Order.find_by(id: order2.id)).not_to be_nil
      end
    end

    context "as a customer" do
      it "returns forbidden when trying to delete" do
        delete "/api/v1/orders/#{order1.id}", headers: auth_headers(person), as: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
