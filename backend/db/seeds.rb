# db/seeds.rb

puts "Cleaning database..."
# Opcional: Descomenta la línea de abajo si quieres empezar de cero cada vez
# Order.destroy_all && Person.destroy_all

# 1. Create Admin
admin = Person.find_or_create_by!(email: 'admin@example.com') do |p|
  p.first_name = 'Super'
  p.last_name = 'Admin'
  p.password = 'password123'
  p.password_confirmation = 'password123'
  p.role = :admin
end
puts "Created Admin: #{admin.email}"

# 2. Create 3 Customers
customers_data = [
  { email: 'john.doe@example.com', first_name: 'John', last_name: 'Doe' },
  { email: 'jane.smith@example.com', first_name: 'Jane', last_name: 'Smith' },
  { email: 'paul.athomp@example.com', first_name: 'Paul', last_name: 'Athomp' }
]

customers_data.each do |data|
  customer = Person.find_or_create_by!(email: data[:email]) do |p|
    p.first_name = data[:first_name]
    p.last_name = data[:last_name]
    p.password = 'password123'
    p.password_confirmation = 'password123'
    p.role = :customer
  end
  puts "Created Customer: #{customer.email}"

  # 3. Create 3 orders per customer (2 pending, 1 confirmed/shipped)

  # Pending Order 1
  Order.find_or_create_by!(number: "ORD-#{customer.first_name.upcase}-P1") do |o|
    o.person = customer
    o.status = 'pending'
    o.total_amount = rand(100.0..500.0).round(2)
    o.order_date = Date.current
    o.notes = "First pending order for #{customer.first_name}"
  end

  # Pending Order 2
  Order.find_or_create_by!(number: "ORD-#{customer.first_name.upcase}-P2") do |o|
    o.person = customer
    o.status = 'pending'
    o.total_amount = rand(100.0..500.0).round(2)
    o.order_date = Date.current
    o.notes = "Second pending order for #{customer.first_name}"
  end

  # Other Status Order (Confirmed or Shipped)
  random_status = [ 'confirmed', 'shipped' ].sample
  Order.find_or_create_by!(number: "ORD-#{customer.first_name.upcase}-S3") do |o|
    o.person = customer
    o.status = random_status
    o.total_amount = rand(100.0..500.0).round(2)
    o.order_date = Date.yesterday
    o.notes = "A #{random_status} order for #{customer.first_name}"
  end
end

puts "Seed finished! Total orders: #{Order.count}"
