# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create seed data for development
# Create first person
person1 = Person.find_or_create_by!(email: 'john.doe@example.com') do |person|
  person.first_name = 'John'
  person.last_name = 'Doe'
  person.password = 'password123'
  person.password_confirmation = 'password123'
end

# Create second person
person2 = Person.find_or_create_by!(email: 'jane.smith@example.com') do |person|
  person.first_name = 'Jane'
  person.last_name = 'Smith'
  person.password = 'password123'
  person.password_confirmation = 'password123'
end

Order.find_or_create_by!(person: person1, number: "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}") do |order|
  order.status = 'pending'
  order.total_amount = 150.00
  order.order_date = Date.current
  order.notes = 'First pending order for John Doe'
end

Order.find_or_create_by!(person: person2, number: "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}") do |order|
  order.status = 'pending'
  order.total_amount = 250.00
  order.order_date = Date.current
  order.notes = 'First pending order for Jane Smith'
end
