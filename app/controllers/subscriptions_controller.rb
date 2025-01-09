class SubscriptionsController < ApplicationController
  before_action :set_price_id, only: [:buy, :subscribed]
  before_action :require_logged_in, only: [:edit]

  def buy
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    @session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      allow_promotion_codes: true,
      billing_address_collection: 'required',
      mode: 'subscription',
      line_items: [
        {
          price: @price_id, quantity: 1
        },
      ],
      success_url: app_route(app_subscribed_url(current_app, clients: params[:clients])),
      cancel_url: app_route(app_subscriptions_url(current_app))
    })
  end

  def subscribed
    # Create plan and plan category
    title = "EnDG-#{params[:clients]}"
    plan_category = PlanCategory.find_or_create_by(name: title, status: 'yes')
    plan = Plan.find_or_create_by(title: title, guests_limit: params[:clients], plan_category_id: plan_category.id, status: 'yes')

    stripe_user = Stripe::Customer.list({limit: 1}).data[0]
    flash[:success] = t('subscription.subscribed_successfully')
    password = SecureRandom.hex(8)
    sub_id = Stripe::Subscription.list({customer: stripe_user.id}).data.first.id
    CreateAppWithAdmin.call(
      sub_id: sub_id,
      stripe_customer_id: stripe_user.id,
      name: stripe_user.name,
      email: stripe_user.email,
      password: password,
      plan_id: plan.id
    )
    UserMailer.welcome_email(User.last, password,current_app).deliver_now
    redirect_to app_route(new_app_user_session_path(current_app))
  end

  private
  def set_price_id
    @price_id = if params[:clients] == "250"
                  ENV['250_PRODUCT']
                elsif params[:clients] == "500"
                  ENV['500_PRODUCT']
                elsif params[:clients] == "1000"
                  ENV['1000_PRODUCT']
                elsif params[:clients] == "unlimited"
                  ENV['unlimited_PRODUCT']
                end
  end
end
