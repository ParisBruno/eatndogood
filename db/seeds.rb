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
    name: 'ITR-250',
    status: 'yes'
  },
  {
    name: 'ITR-500',
    status: 'yes'
  },
  {
    name: 'ITR-1000',
    status: 'yes'
  },
  {
    name: 'G4J-250',
    status: 'yes'
  },
  {
    name: 'G4J-500',
    status: 'yes'
  },
  {
    name: 'G4J-1000',
    status: 'yes'
  },
  {
    name: 'RSW-250',
    status: 'yes'
  },
  {
    name: 'RSW-500',
    status: 'yes'
  },
  {
    name: 'RSW-1000',
    status: 'yes'
  },{
    name: 'S4Y-250',
    status: 'yes'
  },
  {
    name: 'S4Y-500',
    status: 'yes'
  },
  {
    name: 'S4Y-1000',
    status: 'yes'
  },{
    name: 'EnDG-250',
    status: 'yes'
  },
  {
    name: 'EnDG-500',
    status: 'yes'
  },
  {
    name: 'EnDG-1000',
    status: 'yes'
  }
]

plan_categories.each do |cate|
  PlanCategory.find_or_create_by!(cate)
end

itr_250 = PlanCategory.where(name: 'ITR-250').first
g4j_250 = PlanCategory.where(name: 'G4J-250').first
rsw_250 = PlanCategory.where(name: 'RSW-250').first
s4y_250 = PlanCategory.where(name: 'S4Y-250').first
endg_250 = PlanCategory.where(name: 'EnDG-250').first

plans = [
  {
    title: itr_250.name,
    guests_limit: 250,
    plan_category_id: itr_250.id,
    status: 'yes'
  },
  {
    title: g4j_250.name,
    guests_limit: 250,
    plan_category_id: g4j_250.id,
    status: 'yes'
  },
  {
    title: rsw_250.name,
    guests_limit: 250,
    plan_category_id: rsw_250.id,
    status: 'yes'
  },
  {
    title: s4y_250.name,
    guests_limit: 250,
    plan_category_id: s4y_250.id,
    status: 'yes'
  },
  {
    title: endg_250.name,
    guests_limit: 250,
    plan_category_id: endg_250.id,
    status: 'yes'
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

# Creating apps and users
plan = Plan.find_by(title: "G4J-250")
app1 = App.find_or_create_by(name: "glow4joylive", slug: "glow4joylive", plan_id: plan.id, selected_languages: ["en_primary", "es_secondary", "de_secondary", "it_secondary", "fr_secondary"], parent_type: 'glow4joy')
Page.find_or_create_by(name: "Welcome", title: "Welcome!", content: "Lorem Ipsum", destination: "welcome", app_id: app1.id)
Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about", app_id: app1.id)
user = User.create(email: "glow4joy@gmail.com", password: "admin123", admin: true, first_name: "FirstUser", password_confirmation: "admin123", app_id: app1.id, chef: true, guest: false)
chef = Chef.find_or_create_by!(user_id: user.id, admin: true)
user.update(chef_id: chef.id)

plan = Plan.find_by(title: "ITR-250")
app2 = App.find_or_create_by(name: "itoprecipeslive", slug: "itoprecipeslive", plan_id: plan.id, selected_languages: ["en_primary", "es_secondary", "de_secondary", "it_secondary", "fr_secondary"], parent_type: 'itoprecipes')
Page.find_or_create_by(name: "Welcome", title: "Welcome!", content: "Lorem Ipsum", destination: "welcome", app_id: app2.id)
Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about", app_id: app2.id)
user = User.create(email: "itoprecipes@gmail.com", password: "admin123", admin: true, first_name: "FirstUser", password_confirmation: "admin123", app_id: app2.id, chef: true, guest: false)
chef = Chef.find_or_create_by!(user_id: user.id, admin: true)
user.update(chef_id: chef.id)

plan = Plan.find_by(title: "S4Y-250")
app3 = App.find_or_create_by(name: "strive4youlive", slug: "strive4youlive", plan_id: plan.id, selected_languages: ["en_primary", "es_secondary", "de_secondary", "it_secondary", "fr_secondary"], parent_type: 'strive4you')
Page.find_or_create_by(name: "Welcome", title: "Welcome!", content: "Lorem Ipsum", destination: "welcome", app_id: app3.id)
Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about", app_id: app3.id)
user = User.create(email: "strive4you@gmail.com", password: "admin123", admin: true, first_name: "FirstUser", password_confirmation: "admin123", app_id: app3.id, chef: true, guest: false)
chef = Chef.find_or_create_by!(user_id: user.id, admin: true)
user.update(chef_id: chef.id)

plan = Plan.find_by(title: "RSW-250")
app4 = App.find_or_create_by(name: "rockystepswaylive", slug: "rockystepswaylive", plan_id: plan.id, selected_languages: ["en_primary", "es_secondary", "de_secondary", "it_secondary", "fr_secondary"], parent_type: 'rockystepsway')
Page.find_or_create_by(name: "Welcome", title: "Welcome!", content: "Lorem Ipsum", destination: "welcome", app_id: app4.id)
Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about", app_id: app4.id)
user = User.create(email: "rockystepsway@gmail.com", password: "admin123", admin: true, first_name: "RockyUser", password_confirmation: "admin123", app_id: app4.id, chef: true, guest: false)
chef = Chef.find_or_create_by!(user_id: user.id, admin: true)
user.update(chef_id: chef.id)
# Create agreement category only for rockystepswaylive
Style.create(id: 138, name: "Exercise", app_id: app4.id)

plan = Plan.find_by(title: "EnDG-250")
app5 = App.find_or_create_by(name: "eatndogoodlive", slug: "eatndogoodlive", plan_id: plan.id, selected_languages: ["en_primary", "es_secondary", "de_secondary", "it_secondary", "fr_secondary"], parent_type: 'eatndogood')
Page.find_or_create_by(name: "Welcome", title: "Welcome!", content: "Lorem Ipsum", destination: "welcome", app_id: app5.id)
Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about", app_id: app5.id)
user = User.create(email: "eatndogood@gmail.com", password: "admin123", admin: true, first_name: "EatnDoGoodUser", password_confirmation: "admin123", app_id: app5.id, chef: true, guest: false)
chef = Chef.find_or_create_by!(user_id: user.id, admin: true)
user.update(chef_id: chef.id)
