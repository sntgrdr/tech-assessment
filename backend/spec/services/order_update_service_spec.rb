require 'rails_helper'

RSpec.describe OrderUpdateService, type: :service do
  let!(:person) { create(:person) }
  let!(:order) { create(:order, person: person, status: 'pending') }

  describe '.update_order' do
    it 'updates order with valid status transition' do
      order_params = { status: 'confirmed' }

      result = OrderUpdateService.update_order(order, order_params)

      expect(result.status).to eq('confirmed')
    end

    it 'raises error for invalid status transition' do
      order_params = { status: 'delivered' }

      expect {
        OrderUpdateService.update_order(order, order_params)
      }.to raise_error(OrderUpdateService::InvalidOrderError, 'Invalid status transition from pending to delivered')
    end

    it 'updates order with non-status parameters' do
      order_params = { notes: 'Updated notes' }

      result = OrderUpdateService.update_order(order, order_params)

      expect(result.notes).to eq('Updated notes')
    end
  end
end
