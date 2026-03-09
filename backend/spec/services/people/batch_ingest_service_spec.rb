require 'rails_helper'

RSpec.describe People::BatchIngestService do
  let(:source) { :crm }
  let(:person_data) do
    {
      external_id: 'crm_123',
      email: 'john@example.com',
      first_name: 'John',
      last_name: 'Doe',
      updated_at: Time.current
    }
  end

  describe '#call' do
    context 'when people_data is empty' do
      it 'returns an empty array' do
        service = described_class.new(source, [])
        expect(service.call).to eq([])
      end
    end

    context 'when there is a single person in the batch' do
      let(:service) { described_class.new(source, [ person_data ]) }

      it 'creates the person and external identity' do
        expect { service.call }.to change(Person, :count).by(1)
        expect(ExternalIdentity.count).to eq(1)

        person = service.call.first
        expect(person.email).to eq(person_data[:email].downcase)
      end
    end

    context 'when there are multiple people in the batch' do
      let(:people_batch) do
        [
          person_data,
          person_data.merge(email: 'jane@example.com', external_id: 'crm_456', updated_at: Time.current)
        ]
      end
      let(:service) { described_class.new(source, people_batch) }

      it 'creates all people and external identities' do
        expect { service.call }.to change(Person, :count).by(2)
        expect(ExternalIdentity.count).to eq(2)
      end
    end

    context 'when a record in the batch is invalid' do
      let(:people_batch) do
        [
          person_data,
          person_data.except(:email)
        ]
      end
      let(:service) { described_class.new(source, people_batch) }

      it 'raises an ArgumentError and rolls back all changes' do
        expect { service.call }.to raise_error(ArgumentError, /Email is required/)
        expect(Person.count).to eq(0)
        expect(ExternalIdentity.count).to eq(0)
      end
    end

    context 'when some records already exist' do
      let!(:existing_person) { Person.create!(first_name: 'Jane', last_name: 'Doe', email: 'jane@example.com') }
      let(:people_batch) do
        [
          person_data,
          { email: 'jane@example.com', first_name: 'Jane', last_name: 'Smith', external_id: 'crm_456', updated_at: Time.current }
        ]
      end
      let(:service) { described_class.new(source, people_batch) }

      it 'updates existing people and creates new ones' do
        expect { service.call }.to change(Person, :count).by(1)
        updated_person = Person.find_by(email: 'jane@example.com')
        expect(updated_person.last_name).to eq('Smith')

        expect(ExternalIdentity.count).to eq(2)
      end
    end
  end
end
