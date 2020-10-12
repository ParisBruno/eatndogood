class PagePreview < ApplicationRecord
  belongs_to :page

  has_one_attached :page_img
  validates :page_img, blob: { content_type: %w(image/png image/jpeg image/jpg image/gif)}, unless: -> {page_img.blank?}

  before_create :update_attrs

  translates :title, :content, fallbacks_for_empty_translations: true
  globalize_accessors :locales => I18n.available_locales, :attributes => [:title, :content]

  def update_attrs
    # self.title = page.title
    self.name = page.name
    self.destination = page.destination
    # self.page_img = page.page_img
  end

  def copy_page_image
    unless page.page_img.attachment.nil?
      p "comes here #{page.id}"
      cop = page.dup
      dup.page_img.attach(
        io: StringIO.new(page.page_img.download),
        filename: page.page_img.filename,
        content_type: page.page_img.content_type
      )
    end
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
end
