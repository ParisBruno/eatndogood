FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password {'123456'}
    email { Faker::Internet.email(name: first_name) }
    app
  end
end