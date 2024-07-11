module StaffOrderHelper
  def recipes_for_staff_order(order)
    recipe_ids = @order.line_items.pluck(:recipe_id)
    recipes = Recipe.joins(:recipe_ingredients).where(chef_id: @chef_ids, is_draft: false).where.not(price: 0, id: recipe_ids).order(:name).uniq
    recipes = recipes.select{|recipe| recipe if (recipe.is_inventory_count == false || (recipe.is_inventory_count == true && recipe.inventory_count > 0))}

    # Group recipes by style_ids
    recipes_with_category = recipes.group_by(&:style_ids)

    # Sort categories by name
    sorted_categories = recipes_with_category.keys.map do |style_ids|
      Style.find(style_ids[0])
    end.sort_by(&:name)

    dropdown_data = []

    # Iterate over sorted categories and build the dropdown data
    sorted_categories.each do |category|
      dropdown_data << [category.name, category.name, { disabled: true }]
      recipes_with_category[[category.id]].each do |recipe|
          dropdown_data << [recipe.name.truncate_words(3), recipe.id]
      end
    end

    dropdown_data
  end
end
