require 'rails_helper'

RSpec.describe 'Api::V1::PeopleController', type: :request do
  let!(:person1) { create(:person, email: 'john@example.com', department: 'Engineering') }
  let!(:person2) { create(:person, email: 'jane@example.com', department: 'HR') }
  let!(:person3) { create(:person, email: 'bob@example.com', department: 'Engineering') }

  before do
    create(:external_identity, person: person1, source: 'crm', external_id: 'crm_1')
    create(:external_identity, person: person2, source: 'hrm', external_id: 'hrm_2')
    create(:external_identity, person: person3, source: 'crm', external_id: 'crm_3')
  end

  describe 'GET /api/v1/people' do
    context 'without filters' do
      it 'returns all people with pagination info' do
        get '/api/v1/people'

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)

        expect(body['people'].size).to eq(3)
        expect(body['pagination']).to include('page', 'pages', 'count')
      end
    end

    context 'filtering by email' do
      it 'returns only the matched person' do
        get '/api/v1/people', params: { email: 'john@example.com' }

        body = JSON.parse(response.body)
        expect(body['people'].map { |p| p['email'] }).to contain_exactly('john@example.com')
      end
    end

    context 'filtering by department' do
      it 'returns only people in that department' do
        get '/api/v1/people', params: { department: 'Engineering' }

        body = JSON.parse(response.body)
        expect(body['people'].map { |p| p['department'] }).to all(eq('Engineering'))
      end
    end

    context 'filtering by source' do
      it 'returns only people with that source in external_identities' do
        get '/api/v1/people', params: { source: 'hrm' }

        body = JSON.parse(response.body)
        expect(body['people'].map { |p| p['external_identities'].first['source'] }).to all(eq('hrm'))
      end
    end

    context 'pagination' do
      before do
        25.times do |i|
          p = create(:person, email: "example#{i}@example.com")
          create(:external_identity, person: p, source: 'crm', external_id: "crm_#{i+10}")
        end
      end

      it 'returns 20 items on the first page by default' do
        get '/api/v1/people'

        body = JSON.parse(response.body)
        expect(body['people'].size).to eq(20)
        expect(body['pagination']['page']).to eq(1)
      end

      it 'returns remaining items on the second page' do
        get '/api/v1/people', params: { page: 2 }

        body = JSON.parse(response.body)
        expect(body['people'].size).to eq(8)
        expect(body['pagination']['page']).to eq(2)
      end
    end
  end

  describe 'GET /api/v1/people/:id' do
    context 'person exists' do
      it 'returns the person details including external_identities' do
        get "/api/v1/people/#{person1.id}"

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['id']).to eq(person1.id)
        expect(body['email']).to eq(person1.email)
        expect(body['external_identities'].first['source']).to eq('crm')
      end
    end

    context 'person does not exist' do
      it 'returns 404 not found' do
        get '/api/v1/people/999999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
