class AppsController < ApplicationController

  def update
    # Update plan in rockystepsway database
    title = "RSW-#{params[:guest]}"
    plan_category = PlanCategory.find_or_create_by(name: title, status: 'yes')
    plan = Plan.find_or_create_by(title: title, guests_limit: params[:guest], plan_category_id: plan_category.id, status: 'yes')
    @app.update!(plan_id: plan.id)
    # Update plan on stripe
    old_item_id = Stripe::Subscription.retrieve(@app.stripe_subscription_id).items.data.first.id
    price_id = ENV["#{params[:guest]}_PRODUCT"]
    Stripe::SubscriptionItem.create({ subscription: @app.stripe_subscription_id, price: price_id, proration_behavior: 'create_prorations' })
    Stripe::SubscriptionItem.delete(old_item_id)
    flash[:success] = t('common.successfully_updated', name: 'App')
    redirect_to table_app_styles_path(@app)
  end
end
