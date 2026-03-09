require 'rails_helper'

RSpec.describe People::QueryService do
  let!(:person1) { create(:person, email: 'john@example.com', department: 'Engineering') }
  let!(:person2) { create(:person, email: 'jane@example.com', department: 'HR') }
  let!(:person3) { create(:person, email: 'bob@example.com', department: 'Engineering') }

  before do
    create(:external_identity, person: person1, source: 'crm', external_id: 'crm_123')
    create(:external_identity, person: person1, source: 'hrm', external_id: 'hrm_123')
    create(:external_identity, person: person2, source: 'hrm', external_id: 'hrm_1234')
    create(:external_identity, person: person3, source: 'hrm', external_id: 'hrm_12345')
  end

  describe '#call' do
    context 'without filters' do
      it 'returns all people paginated' do
        pagy_scope, records = described_class.new.call

        expect(records.size).to eq(3)
        expect(pagy_scope.count).to eq(3)
      end
    end

    context 'filter by email' do
      it 'returns only matching email' do
        pagy_scope, records = described_class.new(email: 'john@example.com').call

        expect(records).to contain_exactly(person1)
      end
    end

    context 'filter by source' do
      it 'returns only matching source' do
        pagy_scope, records = described_class.new(source: 'hrm').call

        expect(records).to contain_exactly(person1, person2, person3)
      end
    end

    context 'filter by department' do
      it 'returns only matching department' do
        pagy_scope, records = described_class.new(department: 'Engineering').call

        expect(records).to contain_exactly(person1, person3)
      end
    end

    context 'combined filters' do
      it 'returns intersection of filters' do
        pagy_scope, records = described_class.new(department: 'Engineering', source: 'hrm').call

        expect(records).to contain_exactly(person1, person3)
      end
    end

    context 'pagination' do
      before do
        25.times { |i| create(:person, email: "example#{i}@example.com") }
      end

      it 'returns only 20 items per page by default' do
        pagy_scope, records = described_class.new.call

        expect(records.size).to eq(20)
        expect(pagy_scope.pages).to be >= 2
      end

      it 'allows requesting a specific page' do
        pagy_scope, records = described_class.new(page: 2).call

        expect(records.size).to eq(8)
      end
    end
  end
end
