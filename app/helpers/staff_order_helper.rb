module StaffOrderHelper
  def recipes_for_staff_order(order)
    recipe_ids = @order.line_items.pluck(:recipe_id)
    Recipe.joins(:recipe_ingredients).where(chef_id: @chef_ids, is_draft: false).where.not(id: recipe_ids).order(created_at: :desc).uniq
  end
end
