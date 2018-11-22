# frozen_string_literal: true
class Page < ActiveRecord::Base
  COLLECTION_DESTINATIONS = %w[welcome about]
  SEPARATOR = '/'

  def self.get_destination(request_path)
    (request_path.split(SEPARATOR) & COLLECTION_DESTINATIONS).first
  end

  def self.hide(_)
    debugger
  end
end
