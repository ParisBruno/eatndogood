require_relative 'boot'

require 'rails/all'
require 'font-awesome-rails'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myrecipes
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.action_cable.mount_path = '/cable'
    # Locales
    I18n.available_locales = %i[en it de fr es]
    config.i18n.fallbacks = [I18n.default_locale]

    # Sidekiq
    config.active_job.queue_adapter = :sidekiq

    #Mailer
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :port           => ENV['MAILGUN_SMTP_PORT'],
      :address        => ENV['MAILGUN_SMTP_SERVER'],
      :user_name      => ENV['MAILGUN_SMTP_LOGIN'],
      :password       => ENV['MAILGUN_SMTP_PASSWORD'],
      :domain         => ENV['MAILGUN_DOMAIN'],
      :authentication => :plain,
    }

    # Use Vips for processing variants.
    config.active_storage.variant_processor = :vips
  end
end
