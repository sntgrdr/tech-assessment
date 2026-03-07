FactoryBot.define do
  factory :order do
    association :person
    status { 'pending' }
    total_amount { 100.50 }
    notes { Faker::Lorem.sentence }
    order_date { Date.current }

    trait :confirmed do
      status { 'confirmed' }
    end

    trait :processing do
      status { 'processing' }
    end

    trait :shipped do
      status { 'shipped' }
    end

    trait :delivered do
      status { 'delivered' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end
  end
end
