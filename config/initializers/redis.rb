# $redis = if Rails.env.production?
#            Redis.new(url: 'redis://localhost:6379/0/cache')
#          else
#            Redis.new(url: 'redis://127.0.0.1:6379/0')
#          end
# uri = ENV["REDIS_URL"] || "redis://localhost:6379/"
# Redis.new(url: uri)