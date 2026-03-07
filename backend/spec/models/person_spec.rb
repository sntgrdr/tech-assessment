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
end
