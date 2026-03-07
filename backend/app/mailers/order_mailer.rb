class OrderMailer < ApplicationMailer
  def confirmation_email(order)
    @order = order
    @person = order.person
    mail(to: @person.email, subject: "Your order ##{@order.number} has been created")
  end
end
