require 'rails_helper'

RSpec.describe People::IngestService do
  describe '#call' do
    People::IngestService::STRATEGIES.each_key do |source|
      context "when source is #{source}" do
        let(:payload) { IngestPayloads::PAYLOADS.fetch(source) }
        subject(:service_call) { described_class.new(source, payload).call }

        context 'when the person does not exist' do
          it 'creates a new person' do
            expect { service_call }.to change(Person, :count).by(1)
            person = service_call
            expect(person.email).to eq(payload[:email].downcase.strip)
          end
        end

        context 'when the person already exists' do
          let!(:person) do
            Person.create!(
              first_name: 'Jane',
              last_name: 'Doe',
              email: payload[:email]
            )
          end

          it 'updates the existing person' do
            expect { service_call }.not_to change(Person, :count)
            person.reload
            expect(person.first_name).to eq(payload[:first_name].strip)
            expect(person.last_name).to eq(payload[:last_name].strip)
          end
        end

        context 'when the external identity does not exist' do
          it 'creates the external identity' do
            person = service_call
            identity = person.external_identities.find_by(
              source: source,
              external_id: payload[:external_id]
            )
            expect(identity).to be_present
            expect(identity.last_synced_at).to be_present
          end
        end

        context 'when the external identity already exists' do
          let!(:person) do
            Person.create!(
              first_name: 'Jane',
              last_name: 'Doe',
              email: payload[:email]
            )
          end

          let!(:identity) do
            person.external_identities.create!(
              source: source,
              external_id: payload[:external_id],
              last_synced_at: 1.day.ago
            )
          end

          it 'updates last_synced_at without creating duplicates' do
            expect { service_call }.to change { identity.reload.last_synced_at }
            expect { service_call }.not_to change(ExternalIdentity, :count)
          end
        end
      end
    end
  end

  describe 'validations' do
    it 'raises if email is missing' do
      expect {
        described_class.new(:crm, { email: nil }).call
      }.to raise_error(ArgumentError, 'Email is required')
    end
  end
end
