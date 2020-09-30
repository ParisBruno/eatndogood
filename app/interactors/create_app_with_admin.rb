class CreateAppWithAdmin
  include Interactor

  def call
    full_name = get_full_name(context.first_name, context.last_name)
    plan = Plan.find context.plan_id
    ActiveRecord::Base.transaction do
      p full_name
      app = App.create!(name: full_name, plan_id: plan.id)
      user = User.create!(
        first_name: context.first_name,
        last_name: context.last_name,
        email: context.email,
        password: context.password,
        password_confirmation: context.password_confirmation,
        admin: true,
        chef: true,
        guest: false,
        app_id: app.id
      )
      create_chef(user.id, admin: true)
      app.create_pages
    end
    # TODO
  end


  def get_full_name(first_name, last_name)
    [first_name, last_name].join(' ').strip
  end

  def create_chef (user_id, admin)
		Chef.create!({user_id: user_id, admin: admin})
	end
end

# CreateAppWithAdmin.call(
#   first_name: 'admin',
#   last_name: 'admin',
#   email: 'yannakoun@gmail.com',
#   password: 'password1234',
#   password_confirmation: 'password1234',
#   plan_id: 3
# )

# Q606WFxf