# frozen_string_literal: true
class Page < ActiveRecord::Base

  COLLECTION_DESTINATIONS = %w[welcome about]
  SEPARATOR = '/'

  has_attached_file :page_img, styles: { large: "900x600>", thumb: "150x100>" }
  validates_attachment_content_type :page_img, content_type: /\Aimage\/.*\z/

  def self.get_destination(request_path)
    destination = (request_path.split(SEPARATOR) & COLLECTION_DESTINATIONS).first
    destination = 'welcome' if destination.nil?
  end

  def self.hide(_)
    debugger
  end
end
