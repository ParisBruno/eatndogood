namespace :fundraise_app do
  task create_data_for_fundraise_child_apps: :environment do

   fundraise_app = App.find_by(slug: "fundraise")
   child_apps = App.where(created_from: 'fundraise')

    child_apps.each do |app|
      # Create styles
      new_app_styles_ids = []
      fundraise_app.styles.each do |style|
        image = style.image.attached? ? style.image.blob : nil
        get_style = Style.find_by(name: style.name, app_id: app.id)
        get_style.update(image: image) if get_style.present?
        #new_app_styles_ids << Style.create(name: style.name, app_id: app.id, image: image).id
      end

      # Create ingredients
      new_app_ingredients_ids = []
      fundraise_app.ingredients.each do |ingredient|
        image = ingredient.image.attached? ? ingredient.image.blob : nil
        get_ingredient = Ingredient.find_by(name: ingredient.name, app_id: app.id)
        get_ingredient.update(image: image) if get_ingredient.present?
        #new_app_ingredients_ids << Ingredient.create(name: ingredient.name, app_id: app.id, image: image).id
      end

      # Create allergens
      new_app_allergens_ids = []
      fundraise_app.allergens.each do |allergen|
        image = allergen.image.attached? ? allergen.image.blob : nil
        get_allergen = Allergen.find_by(name: allergen.name, app_id: app.id)
        get_allergen.update(image: image) if get_allergen.present?
        #new_app_allergens_ids << Allergen.create(name: allergen.name, app_id: app.id, image: image).id
      end

      # Get chef ids
      chef_ids = fundraise_app.chefs.pluck(:id)

      # Create recipes
      fundraise_app_recipes = Recipe.where(chef_id: chef_ids)

      # Get child app chef
      chef = Chef.find_by(user_id: app.users.where(admin: true))

      fundraise_app_recipes.each do |recipe|
        food_image = recipe.food_image.attached? ? recipe.food_image.blob : nil
        gift_card_image = recipe.gift_card_image.attached? ? recipe.gift_card_image.blob : nil
        get_recipe = Recipe.find_by(chef_id: chef.id, name: recipe.name)

        # Assign styles to recipe
        # fundraise_recipe_styles = Style.where(id: new_app_styles_ids, name: recipe.styles.to_a.pluck(:name))
        # new_recipe.styles << fundraise_recipe_styles.to_a

        # Assign ingredients to recipe
        # fundraise_recipe_ingredients = Ingredient.where(id: new_app_ingredients_ids, name: recipe.ingredients.to_a.pluck(:name))
        # new_recipe.ingredients << fundraise_recipe_ingredients.to_a

        # Assign allergens to recipe
        # fundraise_recipe_allergens = Allergen.where(id:new_app_allergens_ids, name: recipe.allergens.to_a.pluck(:name))
        # new_recipe.allergens << fundraise_recipe_allergens.to_a

        # Save recipe
        get_recipe.update(food_image: food_image) if food_image.present?
        get_recipe.update(gift_card_image: gift_card_image) if gift_card_image.present?
      end
    end
  end
end
