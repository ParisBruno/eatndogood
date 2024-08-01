require 'google_maps_service'

# Initialize the Google Maps client
GoogleMapsService.configure do |config|
  config.key = ENV['GOOGLE_MAP_API_KEY']
end

$gmaps = GoogleMapsService::Client.new
