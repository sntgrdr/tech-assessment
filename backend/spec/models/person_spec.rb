require 'rails_helper'

RSpec.describe Person, type: :model do
  subject { build(:person) }

  describe 'associations' do
    it { should have_many(:external_identities).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_uniqueness_of(:email) }

    it 'is invalid with improperly formatted email' do
      person = build(:person, email: 'invalid_email')
      expect(person).not_to be_valid
    end
  end
end
