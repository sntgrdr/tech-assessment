require 'rails_helper'

RSpec.describe 'Ingest API', type: :request do
  let(:payload) do
    {
      external_id: 'crm_123',
      email: 'john@example.com',
      first_name: 'John',
      last_name: 'Doe'
    }
  end

  describe 'POST /api/v1/ingest/:source' do
    context 'when the request is valid' do
      it 'creates a person and external identity' do
        post '/api/v1/ingest/crm', params: payload

        expect(response).to have_http_status(:ok)
        expect(Person.count).to eq(1)
        expect(ExternalIdentity.count).to eq(1)

        body = JSON.parse(response.body)
        expect(body['id']).to be_present
      end
    end

    context 'when email is missing' do
      it 'returns validation error message' do
        post '/api/v1/ingest/crm', params: payload.except(:email)

        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Email is required')
      end
    end

    context 'when the source is unknown' do
      it 'returns an unknown source error' do
        post '/api/v1/ingest/unknown', params: payload

        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Unknown source')
      end
    end
  end
end
