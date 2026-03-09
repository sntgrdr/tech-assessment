FactoryBot.define do
  factory :person do
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    company { Faker::Company.name }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    job_title { Faker::Job.title }
    department { Faker::Name.name }
    manager_email { Faker::Internet.email }
    start_date { Faker::Date.between(from: "2020-01-01", to: "2025-12-31") }
  end
end
