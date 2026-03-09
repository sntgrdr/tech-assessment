FactoryBot.define do
  factory :external_identity do
    association :person

    source { %w[crm hrm].sample }
    sequence(:external_id) { |n| "external_id_#{n}" }
    last_synced_at { Time.current }
  end
end
