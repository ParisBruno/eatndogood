# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#Page.find_or_create_by(name: "Welcome", title: "Welcome!", content: "Lorem Ipsum", destination: "welcome")
#Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about")

plan_categories = [
  {
    name: 'Family & Friends',
    status: 'yes'
  },
  {
    name: 'Professionals',
    status: 'yes'
  },
  {
    name: 'Entrepreneurs',
    status: 'yes'
  },
  {
    name: 'Enterprise',
    status: 'yes'
  }
]

plan_categories.each do |cate|
  PlanCategory.find_or_create_by!(cate)
end

family_cate = PlanCategory.where(name: 'Family & Friends').first
professional_cate = PlanCategory.where(name: 'Professionals').first
entrep_cate = PlanCategory.where(name: 'Entrepreneurs').first
enterprise_cate = PlanCategory.where(name: 'Enterprise').first

plans = [
  
  {
    code: 'V1',
    title: '10 chefs',
    chefs_limit: 10,
    guests_limit: 0,
    recipes_limit: 110,
    plan_category_id: !family_cate.nil? ? family_cate.id : 0
  },
  {
    code: 'V2',
    title: '20 chefs',
    chefs_limit: 20,
    guests_limit: 0,
    recipes_limit: 220,
    plan_category_id: !family_cate.nil? ? family_cate.id : 0
  },
  {
    code: 'V1',
    title: '100 guests',
    chefs_limit: 1,
    guests_limit: 100,
    recipes_limit: 110,
    plan_category_id: !professional_cate.nil? ? professional_cate.id : 0
  },
  {
    code: 'V2',
    title: '250 guests',
    chefs_limit: 1,
    guests_limit: 250,
    recipes_limit: 110,
    plan_category_id: !professional_cate.nil? ? professional_cate.id : 0
  },
  {
    code: 'V1',
    title: '250 guests',
    guests_limit: 250,
    recipes_limit: 150,
    plan_category_id: !entrep_cate.nil? ? entrep_cate.id : 0
  },
  {
    code: 'V2',
    title: '500 guests',
    guests_limit: 500,
    recipes_limit: 150,
    plan_category_id: !entrep_cate.nil? ? entrep_cate.id : 0
  },
  {
    code: 'V3',
    title: '1000 guests',
    guests_limit: 1000,
    recipes_limit: 150,
    plan_category_id: !entrep_cate.nil? ? entrep_cate.id : 0
  },
  {
      title: 'Enterprise',
      recipes_limit: 200,
      plan_category_id: !enterprise_cate.nil? ? enterprise_cate.id : 0
  },
  {
      title: 'Free',
      chefs_limit: 0,
      guests_limit: 0,
      recipes_limit: 10
  }
]

plans.each do |plan|
  Plan.find_or_create_by(plan)
end

categories = [
  { name: 'Appetizers' },
  { name: 'Soups' },
  { name: 'Entrees' },
  { name: 'Sides' },
  { name: 'Pizza' },
  { name: 'Sandwich' },
  { name: 'Desserts' },
  { name: 'Beverages' },
  { name: 'Combos' },
  { name: 'Specials' }
]

categories.each do |category|
  Category.find_or_create_by(category)
end

entrees_subcategories = [
  { name: 'Beef' },
  { name: 'Chicken' },
  { name: 'Pork' },
  { name: 'Seafood' },
  { name: 'Vegetarian' }
]

beverages_subcategories = [
  { name: 'Wine' },
  { name: 'Beer' },
  { name: 'Spirits' },
  { name: 'Soda' },
  { name: 'Coffee' },
  { name: 'others' }
]

entrees_subcategories.each do |subcategory|
  entrees_category = Category.find_or_create_by!(name: 'Entrees')
  Subcategory.find_or_create_by(category_id: entrees_category.id, name: subcategory[:name])
end

beverages_subcategories.each do |subcategory|
  beverages_category = Category.find_or_create_by!(name: 'Beverages')
  Subcategory.find_or_create_by(category_id: beverages_category.id, name: subcategory[:name])
end

other_subcategories_names = Category.where.not(name: ['Entrees', 'Beverages']).pluck(:id, :name)

other_subcategories_names.each do |subcategory|
  Subcategory.find_or_create_by!(category_id: subcategory[0], name: subcategory[1])
end