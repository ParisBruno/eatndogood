role :app, %w[itoprecipeusr@162.216.19.95]
role :web, %w[itoprecipeusr@162.216.19.95]
role :db, %w[itoprecipeusr@162.216.19.95]

set :branch, 'master'
server '162.216.19.95', user: 'itoprecipeusr', roles: %w[app], my_property: :my_value