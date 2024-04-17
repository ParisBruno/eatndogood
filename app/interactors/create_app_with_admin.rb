class CreateAppWithAdmin
  include Interactor

  def call
    plan = Plan.find context.plan_id
    ActiveRecord::Base.transaction do
      app = App.create!(name: context.name, plan_id: plan.id, stripe_customer_id: context.stripe_customer_id, stripe_subscription_id: context.sub_id, parent_type: "eatndogood", created_from: context.created_from)
      user = User.find_by(email: context.email, app_id: app.id)
      password = context.password
      user = User.create!(
        first_name: context.name,
        email: context.email,
        password: password,
        password_confirmation: password,
        admin: true,
        chef: true,
        guest: false,
        app_id: app.id
      )
      chef = create_chef(user.id)
      app.create_pages
      create_app_data(app, chef)
    end
  end

  def create_chef (user_id)
    Chef.find_or_create_by!(user_id: user_id, admin: true)
  end

  def create_app_data(app, chef)
    # Get fundraise app
    fundraise_app = App.find_by(slug: "eatndogoodlive")

    # Create styles
    new_app_styles_ids = []
    fundraise_app.styles.each do |style|
      image = style.image.attached? ? style.image.blob : nil
      new_app_styles_ids << Style.create(name: style.name, app_id: app.id, image: image).id
    end

    # Create ingredients
    new_app_ingredients_ids = []
    fundraise_app.ingredients.each do |ingredient|
      image = ingredient.image.attached? ? ingredient.image.blob : nil
      new_app_ingredients_ids << Ingredient.create(name: ingredient.name, app_id: app.id, image: image).id
    end

    # Create allergens
    new_app_allergens_ids = []
    fundraise_app.allergens.each do |allergen|
      image = allergen.image.attached? ? allergen.image.blob : nil
      new_app_allergens_ids << Allergen.create(name: allergen.name, app_id: app.id, image: image).id
    end

    # Get chef ids
    chef_ids = fundraise_app.chefs.pluck(:id)

    # Create recipes
    fundraise_app_recipes = Recipe.where(chef_id: chef_ids)

    fundraise_app_recipes.each do |recipe|
      food_image = recipe.food_image.attached? ? recipe.food_image.blob : nil
      gift_card_image = recipe.gift_card_image.attached? ? recipe.gift_card_image.blob : nil
      new_recipe = Recipe.new(chef_id: chef.id, price: recipe.price, is_draft: recipe.is_draft, is_subscription: recipe.is_subscription, enable_reservation: recipe.enable_reservation, enable_gift_card: recipe.enable_gift_card, name: recipe.name, description: recipe.description, food_image: food_image, gift_card_image: gift_card_image)

      # Assign styles to recipe
      fundraise_recipe_styles = Style.where(id: new_app_styles_ids, name: recipe.styles.to_a.pluck(:name))
      new_recipe.styles << fundraise_recipe_styles.to_a

      # Assign ingredients to recipe
      fundraise_recipe_ingredients = Ingredient.where(id: new_app_ingredients_ids, name: recipe.ingredients.to_a.pluck(:name))
      new_recipe.ingredients << fundraise_recipe_ingredients.to_a

      # Assign allergens to recipe
      fundraise_recipe_allergens = Allergen.where(id:new_app_allergens_ids, name: recipe.allergens.to_a.pluck(:name))
      new_recipe.allergens << fundraise_recipe_allergens.to_a

      # Save recipe
      new_recipe.save
    end
  end
end
