class Page < ActiveRecord::Base
  COLLECTION_DESTINATIONS = ["welcome", "about"]
  SEPARATOR = "/"

  def self.get_destination(request_path)
    (request_path.split(SEPARATOR) & COLLECTION_DESTINATIONS).first
  end

  def self.hide(content)
    debugger
  end
end
