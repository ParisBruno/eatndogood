class SubscriptionsController < ApplicationController
  before_action :set_price_id, only: [:buy, :subscribed]

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
      success_url: app_subscribed_url(current_app, clients: params[:clients]),
      cancel_url: app_subscriptions_url(current_app)
    })
  end

  def subscribed
    # Create plan and plan category
    title = "RSW-#{params[:clients]}"
    plan_category = PlanCategory.find_or_create_by(name: title, status: 'yes')
    plan = Plan.find_or_create_by(title: title, guests_limit: params[:clients], plan_category_id: plan_category.id, status: 'yes')

    stripe_user = Stripe::Customer.list({limit: 1}).data[0]
    if user = User.find_by(email: stripe_user.email)
      flash[:success] = "User: #{user.full_name}, #{user.email} is already registered!"
    else
      flash[:success] = "Subscribed successfully!, Get your credentials from your email, Thanks!"
      password = SecureRandom.hex(8)
      CreateAppWithAdmin.call(
        name: stripe_user.name,
        email: stripe_user.email,
        password: password,
        plan_id: plan.id
      )
      UserMailer.welcome_email(User.last, password).deliver_now
    end
    redirect_to new_app_user_session_path(current_app)
  end

  private
  def set_price_id
    @price_id = if params[:clients] == "250"
                  ENV['250_PRODUCT']
                elsif params[:clients] == "500"
                  ENV['500_PRODUCT']
                elsif params[:clients] == "1000"
                  ENV['1000_PRODUCT']
                end
  end
end