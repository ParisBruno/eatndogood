class ReportsController < ApplicationController
  before_action :set_team_member
  before_action :check_admin

  def index
    line_items_with_recipe_and_order = LineItem.joins(:recipe).where.not(recipe_id: nil, order_id: nil).where(recipes: { chef_id: @admin_id })
    set_recipes(line_items_with_recipe_and_order)
    set_categories(line_items_with_recipe_and_order)        # use recipe.styles
  end

  def category_sales
    if request.params['format'] == 'xlsx'
      @categories = params['categories']
      @category_gross_sales = params['gross_sales']
      @category_coupon_discount = params['coupon_discount']
      @sale = params['sale']
      @credit_card_sales = params['credit_card_sales']
      @category_fundrasing = params['category_fundrasing']
      @net_sales = params['net_sales']
      @category_cash_total = params['cash_total']
      @category_credit_total = params['credit_total']
      @category_coupon_count = params['coupon_count']
      @category_fundrasing_count = params['fundrasing_count']
      @category_tax = params['tax']
      @category_total_item = params['total_item']
      set_date(params["date_from"], params["date_to"])
    elsif params[:category_sales].present?
      set_date(params[:category_sales][:date_from], params[:category_sales][:date_to])
      set_categories LineItem.joins(:recipe)
                             .where.not(recipe_id: nil, order_id: nil)
                             .where(updated_at: @date_from..@date_to, recipes: { chef_id: @admin_id })
    else
      set_categories LineItem.joins(:recipe)
                             .where.not(recipe_id: nil, order_id: nil)
                             .where(recipes: { chef_id: @admin_id })
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
      @recipe_gross_sales = params['gross_sales']
      @recipe_coupon_discount = params['coupon_discount']
      @sale = params['sale']
      @credit_card_sales = params['credit_card_sales']
      @recipe_fundrasing = params['recipe_fundrasing']
      @net_sales = params['net_sales']
      @recipe_cash_total = params['cash_total']
      @recipe_credit_total = params['credit_total']
      @recipe_coupon_count = params['coupon_count']
      @recipe_fundrasing_count = params['fundrasing_count']
      @recipe_tax = params['tax']
      @recipe_total_item = params['total_item']      
      set_date(params["date_from"], params["date_to"])
      set_recipes LineItem.joins(:recipe)
                          .where.not(recipe_id: nil, order_id: nil)
                          .where(updated_at: @date_from..@date_to, recipes: { chef_id: @admin_id })
    elsif params[:recipe_sales].present?
      set_date(params[:recipe_sales][:date_from], params[:recipe_sales][:date_to])
      set_recipes LineItem.joins(:recipe)
                          .where.not(recipe_id: nil, order_id: nil)
                          .where(updated_at: @date_from..@date_to, recipes: { chef_id: @admin_id })
    else
      set_recipes LineItem.joins(:recipe)
                          .where.not(recipe_id: nil, order_id: nil)
                          .where(recipes: { chef_id: @admin_id })
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
    @recipe_coupon_discount = 0

    order_ids = line_items.pluck(:order_id).uniq
    orders = Order.where(id: order_ids)
    @recipe_coupon_count = orders.where.not(coupon_code: '').count
    @recipe_fundrasing_count = orders.where.not(fundrasing_code: '').count
    
    # @recipe_total_amount = line_items.sum(:amount)
    @recipe_total_item = line_items.sum(:quantity)
    @recipe_gross_sales = line_items.sum(:sub_total)
    @recipe_tax = line_items.sum(:total_tax)

    @recipes = line_items.each_with_object(Hash.new(0)) do |line_item, hash|
      case line_item.order.pay_method
      when "cash"
        @recipe_cash_total += line_item.sub_total
      else
        @recipe_credit_total += line_item.sub_total
      end
      @recipe_coupon_discount += line_item.coupon_discount

      hash[line_item.recipe.name] = recipe_data[line_item.recipe.name]
      hash[line_item.recipe.name]['recipe_item'] += line_item.quantity
      hash[line_item.recipe.name]['recipe_amount'] += line_item.sub_total
      hash[line_item.recipe.name]['recipe_styles'] = line_item.recipe.styles.map(&:name).join
      hash[line_item.recipe.name]['recipe_name'] = line_item.recipe.name
    end
    styles_names = Style.all.pluck(:name)
    styles_data = styles_names.uniq.each_with_object(Hash.new(0)) { |styles_name, hash| hash[styles_name] = Array.new }

    @recipes.each do |key, value|
      styles_data.keys.each { |style| styles_data[value['recipe_styles']] << value if value['recipe_styles'] == style }
    end
    @recipes = styles_data.reject { |key, value| value.empty? }
  end

  def set_categories(line_items)
    styles_names = Style.all.pluck(:name)
    styles_data = styles_names.uniq.each_with_object(Hash.new(0)) { |styles_name, hash| hash[styles_name] = Hash.new(0) }

    @category_credit_total = 0
    @category_cash_total = 0
    @category_coupon_discount = 0
    order_ids = line_items.pluck(:order_id).uniq
    orders = Order.where(id: order_ids)

    @category_coupon_count = orders.where.not(coupon_code: '').count
    @category_fundrasing_count = orders.where.not(fundrasing_code: '').count

    # @category_total_amount = line_items.sum(:amount)
    @category_total_item = line_items.sum(:quantity)
    @category_gross_sales = line_items.sum(:sub_total)
    @category_tax = line_items.sum(:total_tax)

    @categories = line_items.each_with_object(Hash.new(0)) do |line_item, hash|
      case line_item.order.pay_method
      when "cash"
        @category_cash_total += line_item.sub_total
      else
        @category_credit_total += line_item.sub_total
      end
      @category_coupon_discount += line_item.coupon_discount

      style_name = line_item.recipe.styles.first&.name
      if style_name
        hash[style_name] = styles_data[style_name]
        hash[style_name]['category_item'] += line_item.quantity
        hash[style_name]['category_amount'] += line_item.sub_total
      end
    end
  end
end
