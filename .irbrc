if ENV['RAILS_ENV']
  raise "test"
  require 'rubygems'
  require 'hirb'
  Hirb.enable
end