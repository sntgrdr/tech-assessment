require 'rails_helper'

RSpec.describe OrderStatsService, type: :service do
  let!(:person) { create(:person) }

  before do
    # Create test orders for the person
    create(:order, person: person, status: 'pending', total_amount: 100.00, created_at: Date.current)
    create(:order, person: person, status: 'confirmed', total_amount: 200.00, created_at: Date.current)
    create(:order, person: person, status: 'delivered', total_amount: 150.00, created_at: 1.day.ago)
    create(:order, person: person, status: 'cancelled', total_amount: 50.00, created_at: 2.days.ago)
  end

  describe '.get_person_stats' do
    it 'returns comprehensive statistics' do
      stats = OrderStatsService.get_person_stats(person)

      expect(stats[:total_orders]).to eq(4)
      expect(stats[:orders_today]).to eq(2)
      expect(stats[:orders_this_month]).to eq(4)
      expect(stats[:pending_orders]).to eq(1)
      expect(stats[:confirmed_orders]).to eq(1)
      expect(stats[:processing_orders]).to eq(0)
      expect(stats[:shipped_orders]).to eq(0)
      expect(stats[:delivered_orders]).to eq(1)
      expect(stats[:cancelled_orders]).to eq(1)
    end

    it 'calculates total revenue correctly' do
      stats = OrderStatsService.get_person_stats(person)

      # Revenue from confirmed, processing, shipped, and delivered orders
      expected_revenue = 200.00 + 150.00 # confirmed + delivered
      expect(stats[:total_revenue]).to eq(expected_revenue)
    end

    it 'calculates average order value correctly' do
      stats = OrderStatsService.get_person_stats(person)

      # Average of delivered orders only
      expect(stats[:average_order_value]).to eq(150.00)
    end

    it 'returns zero for person with no orders' do
      empty_person = create(:person)
      stats = OrderStatsService.get_person_stats(empty_person)

      expect(stats[:total_orders]).to eq(0)
      expect(stats[:total_revenue]).to eq(0)
      expect(stats[:average_order_value]).to eq(0)
    end
  end
end
