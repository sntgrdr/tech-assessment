require 'rails_helper'

RSpec.describe OrderMailer, type: :mailer do
  describe 'confirmation_email' do
    let(:person) { create(:person, first_name: 'Jean', last_name: 'Oregon', email: 'jean@example.com') }
    let(:order) { create(:order, person: person, total_amount: 150.00) }
    let(:mail) { OrderMailer.confirmation_email(order) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Your order ##{order.number} has been created")
      expect(mail.to).to eq([ person.email ])
    end

    it 'renders the body with order details' do
      expect(mail.body.encoded).to include('Jean')
      expect(mail.body.encoded).to include(order.number)
    end
  end
end
