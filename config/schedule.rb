set :environment, 'production'
set :output, "log/cron.log"

every 1.day, at: '4:30 am' do
  puts "****************************************Running****************************************"
  rake "ssl:send_reminder"
  puts "****************************************Running****************************************"
end
