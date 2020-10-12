FactoryBot.define do
  factory :app do
    name {Faker::Name.name}
    plan_id {7}
  end
end