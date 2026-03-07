require 'rails_helper'

RSpec.describe "Authentication API", type: :request do
  let!(:person) { create(:person, password: 'password123') }

  describe "POST /api/v1/auth/login" do
    it "authenticates with valid credentials" do
      login_params = {
        email: person.email,
        password: 'password123'
      }

      post "/api/v1/auth/login", params: login_params, as: :json

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('token')
      expect(json_response).to have_key('person')
      expect(json_response['person']['email']).to eq(person.email)
    end

    it "rejects invalid credentials" do
      login_params = {
        email: person.email,
        password: 'wrongpassword'
      }

      post "/api/v1/auth/login", params: login_params, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid credentials')
    end

    it "rejects non-existent email" do
      login_params = {
        email: 'nonexistent@example.com',
        password: 'password123'
      }

      post "/api/v1/auth/login", params: login_params, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid credentials')
    end
  end

  describe "POST /api/v1/auth/logout" do
    it "logs out successfully" do
      post "/api/v1/auth/logout", as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Logged out successfully')
    end
  end

  describe "GET /api/v1/auth/current_user" do
    it "returns current user when authenticated" do
      token = AuthService.generate_token(person.id)

      get "/api/v1/auth/current_user", headers: { "Authorization" => "Bearer #{token}" }, as: :json

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['email']).to eq(person.email)
      expect(json_response['first_name']).to eq(person.first_name)
    end

    it "returns unauthorized when no token provided" do
      get "/api/v1/auth/current_user", as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
    end

    it "returns unauthorized when invalid token provided" do
      get "/api/v1/auth/current_user", headers: { "Authorization" => "Bearer invalid_token" }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
    end
  end
end
