require 'rails_helper'

RSpec.describe Person, type: :model do
  describe 'Validations' do
    let(:person) { build(:person) }

    it 'is valid with valid attributes' do
      expect(person).to be_valid
    end

    describe 'email' do
      it 'is required' do
        person.email = nil
        expect(person).not_to be_valid
        expect(person.errors[:email]).to include("can't be blank")
      end

      it 'must be unique' do
        create(:person, email: 'test@example.com')
        duplicate_person = build(:person, email: 'test@example.com')
        expect(duplicate_person).not_to be_valid
        expect(duplicate_person.errors[:email]).to include("has already been taken")
      end

      it 'must be valid email format' do
        person.email = 'invalid-email'
        expect(person).not_to be_valid
        expect(person.errors[:email]).to include("is invalid")
      end
    end

    describe 'first_name' do
      it 'is required' do
        person.first_name = nil
        expect(person).not_to be_valid
        expect(person.errors[:first_name]).to include("can't be blank")
      end

      it 'must be at least 2 characters' do
        person.first_name = 'A'
        expect(person).not_to be_valid
        expect(person.errors[:first_name]).to include("is too short (minimum is 2 characters)")
      end

      it 'must not exceed 50 characters' do
        person.first_name = 'A' * 51
        expect(person).not_to be_valid
        expect(person.errors[:first_name]).to include("is too long (maximum is 50 characters)")
      end
    end

    describe 'last_name' do
      it 'is required' do
        person.last_name = nil
        expect(person).not_to be_valid
        expect(person.errors[:last_name]).to include("can't be blank")
      end

      it 'must be at least 2 characters' do
        person.last_name = 'B'
        expect(person).not_to be_valid
        expect(person.errors[:last_name]).to include("is too short (minimum is 2 characters)")
      end

      it 'must not exceed 50 characters' do
        person.last_name = 'B' * 51
        expect(person).not_to be_valid
        expect(person.errors[:last_name]).to include("is too long (maximum is 50 characters)")
      end
    end

    describe 'phone' do
      it 'can be nil' do
        person.phone = nil
        expect(person).to be_valid
      end

      it 'must not exceed 20 characters' do
        person.phone = '1' * 21
        expect(person).not_to be_valid
        expect(person.errors[:phone]).to include("is too long (maximum is 20 characters)")
      end
    end

    describe 'company' do
      it 'can be nil' do
        person.company = nil
        expect(person).to be_valid
      end

      it 'must not exceed 100 characters' do
        person.company = 'C' * 101
        expect(person).not_to be_valid
        expect(person.errors[:company]).to include("is too long (maximum is 100 characters)")
      end
    end
  end

  describe 'Associations' do
    it 'has many orders' do
      association = Person.reflect_on_association(:orders)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'Helper Methods' do
    let(:person) { create(:person, first_name: 'John', last_name: 'Doe') }

    describe '#orders_count' do
      it 'returns count of associated orders' do
        create_list(:order, 3, person: person)
        expect(person.orders_count).to eq(3)
      end
    end

    describe '#recent_orders' do
      it 'returns recent orders with default limit' do
        create_list(:order, 10, person: person)
        recent = person.recent_orders
        expect(recent.count).to eq(5)
        expect(recent).to eq(person.orders.recent.limit(5))
      end

      it 'returns recent orders with custom limit' do
        create_list(:order, 10, person: person)
        recent = person.recent_orders(3)
        expect(recent.count).to eq(3)
      end
    end

    describe '#orders_by_status' do
      it 'returns orders with specific status' do
        create(:order, person: person, status: 'pending')
        create(:order, person: person, status: 'confirmed')
        create(:order, person: person, status: 'delivered')

        pending_orders = person.orders_by_status('pending')
        expect(pending_orders.count).to eq(1)
        expect(pending_orders.first.status).to eq('pending')
      end
    end
  end
end
