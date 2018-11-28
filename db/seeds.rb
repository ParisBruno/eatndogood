# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Page.find_or_create_by(name: "Welcome", title: "Welcome!", content: "Lorem Ipsum", destination: "welcome")
Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about")

plans = [
  {
    title: 'base'
  },
  {
    title: 'Family & Friends V1',
    chefs_limit: 10,
    guests_limit: 0,
    recipes_limit: 110
  },
  {
    title: 'Family & Friends V2',
    chefs_limit: 20,
    guests_limit: 0,
    recipes_limit: 220
  },
  {
      title: 'Professionals V1',
      chefs_limit: 1,
      guests_limit: 100,
      recipes_limit: 110
  },
  {
      title: 'Professionals V2',
      chefs_limit: 1,
      guests_limit: 250,
      recipes_limit: 110
  },
  {
      title: 'Entrepreneurs V1',
      guests_limit: 250,
      recipes_limit: 150
  },
  {
      title: 'Entrepreneurs V2',
      guests_limit: 500,
      recipes_limit: 150
  },
  {
      title: 'Entrepreneurs V3',
      guests_limit: 1000,
      recipes_limit: 150
  },
  {
      title: 'Enterprise',
      recipes_limit: 200
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