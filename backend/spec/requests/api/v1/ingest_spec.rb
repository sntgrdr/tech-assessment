require 'rails_helper'

RSpec.describe 'Ingest API', type: :request do
  let(:person_data) do
    {
      external_id: 'crm_123',
      email: 'john@example.com',
      first_name: 'John',
      last_name: 'Doe'
    }
  end

  describe 'POST /api/v1/ingest/:source/people' do
    context 'when the request is valid' do
      context 'with a single person in the batch' do
        let(:payload) { { people: [ person_data ] } }

        it 'creates a person and external identity' do
          post '/api/v1/ingest/crm/people', params: payload, as: :json

          expect(response).to have_http_status(:ok)
          expect(Person.count).to eq(1)
          expect(ExternalIdentity.count).to eq(1)

          body = JSON.parse(response.body)
          expect(body['people'].first['email']).to eq(person_data[:email])
        end
      end

      context 'with multiple people in the batch' do
        let(:payload) do
          {
            people: [
              person_data,
              person_data.merge(email: 'jane@example.com', external_id: 'crm_456')
            ]
          }
        end

        it 'creates all people and their identities' do
          expect {
            post '/api/v1/ingest/crm/people', params: payload, as: :json
          }.to change(Person, :count).by(2)

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when a record in the batch is invalid' do
      let(:payload) do
        {
          people: [
            person_data,
            person_data.except(:email)
          ]
        }
      end

      it 'returns a validation error and rolls back all changes' do
        expect {
          post '/api/v1/ingest/crm/people', params: payload, as: :json
        }.not_to change(Person, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['error']).to be_present
      end
    end

    context 'when the source is unknown' do
      let(:payload) { { people: [ person_data ] } }

      it 'returns an unknown source error' do
        post '/api/v1/ingest/unknown/people', params: payload, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/Unknown source/)
      end
    end
  end
end
