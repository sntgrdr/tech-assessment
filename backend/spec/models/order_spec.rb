require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'Validations' do
    let(:order) { build(:order) }

    it 'is valid with valid attributes' do
      expect(order).to be_valid
    end

    describe 'person' do
      it 'is required' do
        order.person = nil
        expect(order).not_to be_valid
        expect(order.errors[:person]).to include("must exist")
      end
    end

    describe 'number' do
      it 'must be unique' do
        create(:order, number: 'ORD-TEST123')
        duplicate_order = build(:order, number: 'ORD-TEST123')
        expect(duplicate_order).not_to be_valid
        expect(duplicate_order.errors[:number]).to include("has already been taken")
      end

      it 'is auto-generated when blank' do
        order = build(:order, number: nil)
        order.validate
        expect(order.number).to match(/^ORD-\d{8}-[A-F0-9]{6}$/)
      end
    end

    describe 'status' do
      it 'is required' do
        order.status = nil
        expect(order).not_to be_valid
        expect(order.errors[:status]).to include("can't be blank")
      end

      it 'must be a valid status' do
        expect { order.status = 'invalid_status' }.to raise_error(ArgumentError, "'invalid_status' is not a valid status")
      end

      it 'accepts all valid statuses' do
        valid_statuses = %w[pending confirmed processing shipped delivered cancelled]
        valid_statuses.each do |status|
          order.status = status
          expect(order).to be_valid, "Expected status '#{status}' to be valid"
        end
      end
    end

    describe 'total_amount' do
      it 'is required' do
        order.total_amount = nil
        expect(order).not_to be_valid
        expect(order.errors[:total_amount]).to include("can't be blank")
      end

      it 'must be greater than 0' do
        order.total_amount = -10
        expect(order).not_to be_valid
        expect(order.errors[:total_amount]).to include("must be greater than 0")
      end

      it 'accepts valid amounts' do
        order.total_amount = 100.50
        expect(order).to be_valid
      end
    end

    describe 'order_date' do
      it 'is set to current date when blank' do
        order = build(:order, order_date: nil)
        order.validate
        expect(order.order_date).to eq(Date.current)
      end
    end
  end

  describe 'Associations' do
    it 'belongs to person' do
      association = Order.reflect_on_association(:person)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'Enums' do
    it 'defines status enum' do
      expect(Order.statuses).to eq({
        'pending' => 'pending',
        'confirmed' => 'confirmed',
        'processing' => 'processing',
        'shipped' => 'shipped',
        'delivered' => 'delivered',
        'cancelled' => 'cancelled'
      })
    end

    it 'creates scope methods for each status' do
      expect(Order.respond_to?(:pending)).to be_truthy
      expect(Order.respond_to?(:confirmed)).to be_truthy
      expect(Order.respond_to?(:processing)).to be_truthy
      expect(Order.respond_to?(:shipped)).to be_truthy
      expect(Order.respond_to?(:delivered)).to be_truthy
      expect(Order.respond_to?(:cancelled)).to be_truthy
    end
  end

  describe 'Scopes' do
    let!(:person) { create(:person) }
    let!(:order1) { create(:order, person: person, status: 'pending', order_date: 1.day.ago) }
    let!(:order2) { create(:order, person: person, status: 'confirmed', order_date: Date.current) }
    let!(:order3) { create(:order, person: person, status: 'delivered', order_date: 2.days.ago) }

    describe '.by_customer' do
      it 'returns orders for specific person' do
        other_person = create(:person)
        other_order = create(:order, person: other_person)

        expect(Order.by_customer(person.id)).to contain_exactly(order1, order2, order3)
        expect(Order.by_customer(person.id)).not_to include(other_order)
      end
    end

    describe '.by_status' do
      it 'returns orders with specific status' do
        expect(Order.by_status('pending')).to contain_exactly(order1)
        expect(Order.by_status('confirmed')).to contain_exactly(order2)
        expect(Order.by_status('delivered')).to contain_exactly(order3)
      end
    end

    describe '.by_date_range' do
      it 'returns orders within date range' do
        expect(Order.by_date_range(2.days.ago, Date.current)).to contain_exactly(order1, order2, order3)
        expect(Order.by_date_range(Date.current, Date.current)).to contain_exactly(order2)
        expect(Order.by_date_range(3.days.ago, 2.days.ago)).to contain_exactly(order3)
      end
    end

    describe '.recent' do
      it 'returns orders ordered by created_at desc' do
        recent_orders = Order.recent
        expect(recent_orders).to eq([ order3, order2, order1 ])
      end
    end

    describe '.by_number' do
      it 'returns orders with specific number' do
        expect(Order.by_number(order1.number)).to contain_exactly(order1)
        expect(Order.by_number(order2.number)).to contain_exactly(order2)
      end
    end
  end

  describe 'Callbacks' do
    describe 'before_validation on create' do
      it 'generates order number when blank' do
        order = build(:order, number: nil)
        order.validate
        expect(order.number).to match(/^ORD-\d{8}-[A-F0-9]{6}$/)
      end

      it 'sets order date when blank' do
        order = build(:order, order_date: nil)
        order.validate
        expect(order.order_date).to eq(Date.current)
      end

      it 'does not override existing number' do
        existing_number = 'ORD-EXISTING123'
        order = build(:order, number: existing_number)
        order.validate
        expect(order.number).to eq(existing_number)
      end

      it 'does not override existing order_date' do
        existing_date = 1.week.ago.to_date
        order = build(:order, order_date: existing_date)
        order.validate
        expect(order.order_date).to eq(existing_date)
      end
    end
  end
end
