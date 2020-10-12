FactoryBot.define do
  factory :allergen do
    name {"No #{Faker::Food.ingredient}"}
    app { App.first }
    factory :allergen_with_recipes do
      transient do
        recipes_count { 1 }
      end
      after(:create) do |allergen, evaluator|
        create_list(:recipe, evaluator.recipes_count, allergens: [allergen])
      end
    end
  end
end