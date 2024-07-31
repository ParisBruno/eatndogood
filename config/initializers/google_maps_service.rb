require 'google_maps_service'

# Initialize the Google Maps client
GoogleMapsService.configure do |config|
  config.key = ''
end

$gmaps = GoogleMapsService::Client.new
