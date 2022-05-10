class CreateAppWithAdmin
  include Interactor

  def call
    plan = Plan.find context.plan_id
    ActiveRecord::Base.transaction do
      app = App.create!(name: context.name, plan_id: plan.id, parent_type: "rockystepsway")
      user = User.find_by(email: context.email)
      if user.blank?
        password = context.password
        user = User.create!(
          first_name: context.name,
          email: context.email,
          password: password,
          password_confirmation: password,
          admin: true,
          chef: true,
          guest: false,
          app_id: app.id
        )
      end
      create_chef(user.id)
      app.create_pages
    end
  end

  def create_chef (user_id)
    Chef.find_or_create_by!(user_id: user_id, admin: true)
  end
end
