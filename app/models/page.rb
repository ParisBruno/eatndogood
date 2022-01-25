# frozen_string_literal: true
class Page < ActiveRecord::Base

  COLLECTION_DESTINATIONS = %w[welcome about]
  SEPARATOR = '/'

  # has_attached_file :page_img, styles: { large: "900x600>", thumb: "150x100>" }
  has_one_attached :page_img
  has_one_attached :landscape_page_img
  validates :landscape_page_img, blob: { content_type: %w(image/png image/jpeg image/jpg image/gif)}, unless: -> { landscape_page_img.blank? }, aspect_ratio: :landscape

  validates :page_img, blob: { content_type: %w(image/png image/jpeg image/jpg image/gif)}, unless: -> { page_img.blank? }
  validates :page_img, aspect_ratio: :portrait, if: -> { destination == 'welcome' }
  # validates_attachment_content_type :page_img, content_type: /\Aimage\/.*\z/
  has_one :page_preview, dependent: :destroy

  after_create :save_page_preview

  translates :title, :content, fallbacks_for_empty_translations: true
  globalize_accessors :locales => I18n.available_locales, :attributes => [:title, :content]


  def self.get_destination(request_path)
    destination = (request_path.split(SEPARATOR) & COLLECTION_DESTINATIONS).first
    destination = 'welcome' if destination.nil?
    destination
  end

  def self.hide(_)
    debugger
  end

  def self.sizes
    {
      large: { resize: "900x600" },
      thumb: { resize: "150x100" }
    }
  end

  def sized(size)
    self.page_img.variant(Page.sizes[size]).processed
  end

  def save_page_preview
    page_preview = self.page_preview || self.build_page_preview
    page_preview.content = self.content
    page_preview.title = self.title
    page_preview.name = self.name
    page_preview.copy_page_image
    page_preview.save
    
  end
end


# validate :check_landscape

# def check_landscape
#   if photo.width<photo.height
#      errors.add :photo, "is not a landscape." 
#      puts "Error ! not a Landscape Image"
#   else if photo.width>photo.height
#      puts " Landscape Image"
#   end
#   end
# end