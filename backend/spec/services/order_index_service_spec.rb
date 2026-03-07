require 'rails_helper'

RSpec.describe OrderIndexService do
  let(:admin) { create(:person, :admin) }
  let(:customer) { create(:person, :customer) }

  let!(:order_pending) { create(:order, person: customer, status: :pending, total_amount: 100, order_date: 2.days.ago) }
  let!(:order_confirmed) { create(:order, person: customer, status: :confirmed, total_amount: 200, order_date: 1.day.ago) }

  describe '#call' do
    context 'cuando se filtra por status confirmed' do
      let(:params) { { status: 'confirmed' } }
      subject { described_class.new(admin, params).call }

      it 'devuelve solo la orden confirmada en orders_relation' do
        expect(subject[:orders_relation]).to include(order_confirmed)
        expect(subject[:orders_relation]).not_to include(order_pending)
      end

      it 'recalcula el revenue basado solo en las confirmadas' do
        expect(subject[:stats][:total_revenue]).to eq(200.0)
      end

      it 'mantiene los contadores globales (no se filtran por status)' do
        expect(subject[:stats][:total_orders]).to eq(2)
        expect(subject[:stats][:pending_orders]).to eq(1)
        expect(subject[:stats][:confirmed_orders]).to eq(1)
      end
    end

    context 'cuando se filtra por número de orden parcial' do
      let!(:special_order) { create(:order, number: 'ORD-PAUL-S3', person: customer) }
      let(:params) { { number: 'paul' } }
      subject { described_class.new(admin, params).call }

      it 'encuentra la orden ignorando mayúsculas y de forma parcial' do
        expect(subject[:orders_relation]).to include(special_order)
        expect(subject[:stats][:total_orders]).to eq(1)
      end
    end

    context 'filtros de fecha' do
      let(:params) { { from_date: 1.day.ago.to_s, to_date: Time.current.to_s } }
      subject { described_class.new(admin, params).call }

      it 'filtra los contadores globales por fecha' do
        expect(subject[:stats][:total_orders]).to eq(1)
        expect(subject[:stats][:pending_orders]).to eq(0)
      end
    end
  end
end
