$redis = if Rails.env.production?
           Redis.new(url: 'redis://redis.example.com:7372/0')
         else
           Redis.new(url: 'redis://127.0.0.1:6379/0')
         end