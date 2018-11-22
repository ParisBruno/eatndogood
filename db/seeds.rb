# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Page.find_or_create_by(name: "Welcome", title: "Welcome!", content: "Lorem Ipsum", destination: "welcome")
Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about")
User.create!(first_name: "Eduard", last_name: "Bekir", email: "admin@example.com", password: "password", admin: true, chef: true, guest: false)

Plan.find_or_create_by(title: 'base')