FactoryBot.define do
  factory :recipe do
    chef {Chef.first}
    name { Faker::Food.dish }
    summary { Faker::Food.description }
    description { Faker::Lorem.paragraph }
  end
end