FactoryBot.define do
  factory :chef do
    user
    admin_id {user.id}
    my_bio { Faker::Lorem.paragraph }
  end
end