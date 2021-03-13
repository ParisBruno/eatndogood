class ReportsController < ApplicationController
  before_action :check_admin

  def index
    line_items_with_recipe_and_order = LineItem.joins(:recipe).where.not(recipe_id: nil, order_id: nil).where(recipes: { chef_id: check_admin })
    set_recipes(line_items_with_recipe_and_order)
    set_categories(line_items_with_recipe_and_order)        # use recipe.styles
  end

  def category_sales
    if request.params['format'] == 'xlsx'
      @categories = params['categories']
      @category_total_item = params['total_item']
      @category_total_amount =  params['total_amount']
      @category_credit_total = params['credit_total']
      @category_cash_total = params['cash_total']
      @category_tax = params['tax']
      @category_coupon_count = params['coupon_count'] 
      @category_coupon_discount = (params['coupon_discount'].to_f * (-1)).to_s
      @category_fundrasing_count = params['fundrasing_count']
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
    if request.params['format'] == 'xlsx'
      @recipe_total_item = params['total_item']
      @recipe_total_amount =  params['total_amount']
      @recipe_credit_total = params['credit_total']
      @recipe_cash_total = params['cash_total']
      @recipe_tax = params['tax']
      @recipe_coupon_count = params['coupon_count'] 
      @recipe_coupon_discount = (params['coupon_discount'].to_f * (-1)).to_s
      @recipe_fundrasing_count = params['fundrasing_count']
      
      set_date(params["date_from"], params["date_to"])
      set_recipes LineItem.joins(:recipe)
                          .where.not(recipe_id: nil, order_id: nil)
                          .where(created_at: @date_from..@date_to, recipes: { chef_id: check_admin })
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

    @recipe_credit_total = 0
    @recipe_cash_total = 0
    @recipe_coupon_count = 0
    @recipe_coupon_discount = 0
    @recipe_fundrasing_count = 0
    @recipe_tax = 0
    
    @recipes = line_items.each_with_object(Hash.new(0)) do |line_item, hash|
      case line_item.order.pay_method
      when "cash"
        @recipe_cash_total += line_item.order.amount
      else
        @recipe_credit_total += line_item.order.amount
      end
      @recipe_coupon_count += 1 if line_item.order.coupon_code.present?
      @recipe_fundrasing_count += 1 if line_item.order.fundrasing_code.present?
      @recipe_coupon_discount += line_item.order.coupon_discount
      @recipe_tax += line_item.order.total_tax

      hash[line_item.recipe.name] = recipe_data[line_item.recipe.name]
      hash[line_item.recipe.name]['recipe_item'] += line_item.quantity
      hash[line_item.recipe.name]['recipe_amount'] += line_item.order.amount
      hash[line_item.recipe.name]['recipe_styles'] = line_item.recipe.styles.map(&:name).join
      hash[line_item.recipe.name]['recipe_name'] = line_item.recipe.name
    end
    set_recipe_totals(@recipes)
    styles_names = Style.all.pluck(:name)
    styles_data = styles_names.uniq.each_with_object(Hash.new(0)) { |styles_name, hash| hash[styles_name] = Array.new }

    @recipes.each do |key, value|
      styles_data.keys.each { |style| styles_data[value['recipe_styles']] << value if value['recipe_styles'] == style }
    end
    @recipes = styles_data
  end

  def set_categories(line_items)
    styles_names = Style.all.pluck(:name)
    styles_data = styles_names.uniq.each_with_object(Hash.new(0)) { |styles_name, hash| hash[styles_name] = Hash.new(0) }

    @category_credit_total = 0
    @category_cash_total = 0
    @category_coupon_count = 0
    @category_coupon_discount = 0
    @category_fundrasing_count = 0
    @category_tax = 0

    @categories = line_items.each_with_object(Hash.new(0)) do |line_item, hash|
      case line_item.order.pay_method
      when "cash"
        @category_cash_total += line_item.order.amount
      else
        @category_credit_total += line_item.order.amount
      end
      @category_coupon_count += 1 if line_item.order.coupon_code.present?
      @category_fundrasing_count += 1 if line_item.order.fundrasing_code.present?
      @category_coupon_discount += line_item.order.coupon_discount
      @category_tax += line_item.order.total_tax

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
    return current_app_user&.chef_info&.id if current_app_user.admin? && current_app_user.chef_info
    
    redirect_to app_recipes_path(current_app)
  end
end
