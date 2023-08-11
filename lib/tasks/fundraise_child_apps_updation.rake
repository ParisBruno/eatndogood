namespace :fundraise_app do
  task create_data_for_fundraise_child_apps: :environment do

   fundraise_app = App.find_by(slug: "fundraise")
   child_apps = App.where(created_from: 'fundraise')

    child_apps.each do |app|
      # Create styles
      new_app_styles_ids = []
      fundraise_app.styles.each do |style|
        new_app_styles_ids << Style.create(name: style.name, app_id: app.id).id
      end

      # Create ingredients
      new_app_ingredients_ids = []
      fundraise_app.ingredients.each do |ingredient|
        new_app_ingredients_ids << Ingredient.create(name: ingredient.name, app_id: app.id).id
      end

      # Create allergens
      new_app_allergens_ids = []
      fundraise_app.allergens.each do |allergen|
        new_app_allergens_ids << Allergen.create(name: allergen.name, app_id: app.id).id
      end

      # Get chef ids
      chef_ids = fundraise_app.chefs.pluck(:id)

      # Create recipes
      fundraise_app_recipes = Recipe.where(chef_id: chef_ids)

      # Get child app chef
      chef = Chef.find_by(user_id: app.users.where(admin: true))

      fundraise_app_recipes.each do |recipe|
        new_recipe = Recipe.new(chef_id: chef.id, price: recipe.price, is_draft: recipe.is_draft, is_subscription: recipe.is_subscription, enable_reservation: recipe.enable_reservation, enable_gift_card: recipe.enable_gift_card, name: recipe.name, description: recipe.description)

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
end
