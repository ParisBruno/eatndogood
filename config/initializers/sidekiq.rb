# frozen_string_literal: true
redis_config = if Rails.env.production?
                 { url: 'redis://redis.example.com:7372/0' }
               else
                 { url: 'redis://127.0.0.1:6379/0' }
               end

Sidekiq.configure_server { |config| config.redis = redis_config }
Sidekiq.configure_client { |config| config.redis = redis_config }

# CRON configs
schedule_file = 'config/schedule.yml'

if File.exist?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
