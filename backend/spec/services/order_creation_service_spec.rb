require 'rails_helper'

RSpec.describe OrderCreationService, type: :service do
  let!(:person) { create(:person) }

  describe '.create_order' do
    it 'creates a valid order' do
      order_params = {
        status: 'pending',
        total_amount: 100.00,
        notes: 'Test order'
      }

      order = OrderCreationService.create_order(person, order_params)

      expect(order).to be_persisted
      expect(order.person).to eq(person)
      expect(order.status).to eq('pending')
      expect(order.total_amount).to eq(100.00)
    end

    it 'raises error for invalid order' do
      order_params = {
        status: 'pending',
        total_amount: -10
      }

      expect {
        OrderCreationService.create_order(person, order_params)
      }.to raise_error(OrderCreationService::InvalidOrderError, 'Total amount must be greater than 0')
    end
  end
end
