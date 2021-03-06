class ReportsController < ApplicationController
  before_action :check_admin

  def index
    line_items_with_recipe_and_order = LineItem.joins(:recipe)
                                               .where.not(recipe_id: nil, order_id: nil)
                                               .where(recipes: { chef_id: check_admin })
    set_recipes(line_items_with_recipe_and_order)
    set_categories(line_items_with_recipe_and_order)        # use recipe.styles
  end

  def category_sales
    if request.params["format"] == 'xlsx'
      @categories = params["categories"]
      @category_total_item = params["total_item"]
      @category_total_amount =  params["total_amount"]
      set_date(params["date_from"], params["date_to"])
    elsif params[:category_sales].present?
      set_date(params[:category_sales][:date_from], params[:category_sales][:date_to])
      set_categories LineItem.joins(:recipe)
                             .where.not(recipe_id: nil, order_id: nil)
                             .where(created_at: @date_from..@date_to, recipes: { chef_id: check_admin })
    else
      set_categories LineItem.joins(:recipe)
                             .where.not(recipe_id: nil, order_id: nil)
                             .where(recipes: { chef_id: check_admin })
    end

    respond_to do |format|
      format.js { render :category_sales }
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=category_sales.xlsx"
      }
    end
  end

  def recipe_sales
    if request.params["format"] == 'xlsx'
      @recipes = params["recipes"]
      @recipe_total_item = params["total_item"]
      @recipe_total_amount =  params["total_amount"]
      set_date(params["date_from"], params["date_to"])
    elsif params[:recipe_sales].present?
      set_date(params[:recipe_sales][:date_from], params[:recipe_sales][:date_to])
      set_recipes LineItem.joins(:recipe)
                          .where.not(recipe_id: nil, order_id: nil)
                          .where(created_at: @date_from..@date_to, recipes: { chef_id: check_admin })
    else
      set_recipes LineItem.joins(:recipe)
                          .where.not(recipe_id: nil, order_id: nil)
                          .where(recipes: { chef_id: check_admin })
    end

    respond_to do |format|
      format.js { render :recipe_sales }
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=recipe_sales.xlsx"
      }
    end
  end

  private

  def set_date(date_from, date_to)
    @date_from = if date_from.present?
                   date_from
                 else
                   (Date.today - 1.years).strftime("%F")
                 end
    @date_to = if date_to.present?
                 date_to
               else
                 (Date.today + 1.days).strftime("%F")
               end
  end

  def set_recipes(line_items)
    recipe_names = []
    line_items.each { |line_item| recipe_names << line_item.recipe.name }

    recipe_data = recipe_names.uniq.each_with_object(Hash.new(0)) { |recipe_name, hash| hash[recipe_name] = Hash.new(0) } 

    @recipes = line_items.each_with_object(Hash.new(0)) do |line_item, hash|
      hash[line_item.recipe.name] = recipe_data[line_item.recipe.name]
      hash[line_item.recipe.name]['recipe_item'] += line_item.quantity
      hash[line_item.recipe.name]['recipe_amount'] += line_item.order.amount
    end
    set_recipe_totals(@recipes)
  end

  def set_categories(line_items)
    styles_names = Style.all.pluck(:name)
    styles_data = styles_names.uniq.each_with_object(Hash.new(0)) { |styles_name, hash| hash[styles_name] = Hash.new(0) }

    @categories = line_items.each_with_object(Hash.new(0)) do |line_item, hash|
      line_item.recipe.styles.each do |style|
        hash[style.name] = styles_data[style.name]
        hash[style.name]['category_item'] += line_item.quantity
        hash[style.name]['category_amount'] += line_item.order.amount
      end
    end

    set_category_totals(@categories)
  end

  def set_recipe_totals(recipes)
    @recipe_total_item = 0
    @recipe_total_amount = 0
    recipes.each do |key, value|
      @recipe_total_item += value['recipe_item']
      @recipe_total_amount += value['recipe_amount']
    end
  end

  def set_category_totals(categories)
    @category_total_item = 0
    @category_total_amount = 0
    categories.each do |key, value|
      @category_total_item += value['category_item']
      @category_total_amount += value['category_amount']
    end
  end

  def check_admin
    return current_app_user&.chef_id if current_app_user.admin?
    
    redirect_to app_recipes_path(current_app)
  end
end
