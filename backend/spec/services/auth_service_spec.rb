require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe AuthService, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  let!(:person) { create(:person, password: 'password123') }

  describe '.authenticate' do
    it 'authenticates with valid credentials' do
      result = AuthService.authenticate(person.email, 'password123')
      expect(result).to eq(person)
    end

    it 'raises error with invalid password' do
      expect {
        AuthService.authenticate(person.email, 'wrongpassword')
      }.to raise_error(AuthService::AuthenticationError, 'Invalid credentials')
    end

    it 'raises error with invalid email' do
      expect {
        AuthService.authenticate('invalid@example.com', 'password123')
      }.to raise_error(AuthService::AuthenticationError, 'Invalid credentials')
    end

    it 'handles case insensitive email' do
      result = AuthService.authenticate(person.email.upcase, 'password123')
      expect(result).to eq(person)
    end
  end

  describe '.generate_token' do
    it 'generates a valid JWT token' do
      token = AuthService.generate_token(person.id)
      expect(token).to be_a(String)

      decoded = AuthService.decode_token(token)
      expect(decoded['person_id']).to eq(person.id)
      expect(decoded['exp']).to be > Time.current.to_i
    end
  end

  describe '.decode_token' do
    it 'decodes a valid token' do
      token = AuthService.generate_token(person.id)
      decoded = AuthService.decode_token(token)

      expect(decoded['person_id']).to eq(person.id)
      expect(decoded).to have_key('exp')
      expect(decoded).to have_key('iat')
    end

    it 'raises error for expired token' do
      token = nil
      travel_to 2.days.ago do
        token = AuthService.generate_token(person.id)
      end

      expect {
        AuthService.decode_token(token)
      }.to raise_error(AuthService::TokenExpiredError, 'Token has expired')
    end

    it 'raises error for invalid token' do
      expect {
        AuthService.decode_token('invalid_token')
      }.to raise_error(AuthService::TokenInvalidError, 'Invalid token')
    end
  end

  describe '.current_person' do
    it 'returns person for valid token' do
      token = AuthService.generate_token(person.id)
      result = AuthService.current_person(token)
      expect(result).to eq(person)
    end

    it 'returns nil for non-existent person' do
      token = AuthService.generate_token(99999)
      result = AuthService.current_person(token)
      expect(result).to be_nil
    end
  end
end
