require 'rails_helper'

RSpec.describe People::NormalizationService do
  describe '.call' do
    let(:raw_data) do
      {
        email: '  JOHN@Example.COM ',
        first_name: '  John ',
        last_name: ' Doe ',
        phone: '(123) 456-7890',
        company: ' ACME Inc ',
        manager_email: ' MANAGER@Example.COM ',
        start_date: '2026-03-09'
      }
    end

    subject(:normalized) { described_class.call(raw_data) }

    it 'downcases and strips emails' do
      expect(normalized[:email]).to eq('john@example.com')
      expect(normalized[:manager_email]).to eq('manager@example.com')
    end

    it 'strips first_name, last_name, company' do
      expect(normalized[:first_name]).to eq('John')
      expect(normalized[:last_name]).to eq('Doe')
      expect(normalized[:company]).to eq('ACME Inc')
    end

    it 'normalizes phone numbers to digits only' do
      expect(normalized[:phone]).to eq('1234567890')
    end

    it 'parses start_date into Date object' do
      expect(normalized[:start_date]).to eq(Date.parse('2026-03-09'))
    end
  end
end
