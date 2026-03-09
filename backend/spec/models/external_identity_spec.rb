require 'rails_helper'

RSpec.describe ExternalIdentity, type: :model do
  subject { build(:external_identity) }

  describe 'associations' do
    it { should belong_to(:person) }
  end

  describe 'validations' do
    it { should validate_presence_of(:source) }
    it { should validate_presence_of(:external_id) }
    it { should validate_uniqueness_of(:source).scoped_to(:external_id) }
  end
end
