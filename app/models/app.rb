class App < ApplicationRecord
  extend FriendlyId

  friendly_id :app_name, use: :slugged

  belongs_to :plan
  has_many :users, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :service_types, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :ingredients, dependent: :destroy
  has_many :styles, dependent: :destroy
  has_many :allergens, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :autosaves, dependent: :destroy, class_name: 'Autosave'
  # has_many :guests, class_name: 'User', foreign_key: 'user_id'
  # has_many :chefs, class_name: 'Chef', foreign_key: 'admin_id'
  
  
  #Validations
  validates :plan, presence: true
  validates :slug, uniqueness: true

  before_save :downcase_slug
  

  # Callbacks
  # after_create :create_pages


  def app_name
    [
      :name,
      [:name, :id_for_slug]
    ]
  end

  def id_for_slug
    generated_slug = normalize_friendly_id(name)
    reg = ActiveRecord::Base.connection.adapter_name == "PostgreSQL" ? '~*' : 'REGEXP'
    things = self.class.where("slug #{reg} :pattern", pattern: "#{generated_slug}(-[0-9]+)?$")
    things = things.where.not(id: id) unless new_record?
    things.count + 1
  end

  def downcase_slug
    slug = slug.gsub(' ', '_').downcase unless slug.nil?
  end

  def admins
    users.where(admin: true)
  end

  def main_admin
    admins.first
  end

  def chefs
    Chef.where(user_id: users.pluck(:id))
  end

  def recipes
    Recipe.where(chef_id: chefs.pluck(:id))
  end

  def guests
    users.where(guest: true)
  end

  def create_pages
    # if self.main_admin
      # Page.find_or_create_by(name: "Welcome", title: "Welcome To", content: ["Welcome To", app_name, "iTopRecipes App"].join("<br/>"), destination: "welcome", app_id: self.id, admin_name: main_admin.full_name)
      # Page.find_or_create_by(name: "About", title: "About page", content: "about page", destination: "about", app_id: self.id, admin_name: main_admin.full_name)
    # end
    welcome = { name: "Welcome", title: "Welcome To", content: ["Welcome To", name, "RockyStepsWay App"].join("<br/>"), destination: "welcome"}
    about = { name: "About", title: "About page", content: "about page", destination: "about" }
    [welcome,about].map do |elem|
      page_creation(elem)
    end
  end

  def self.fundraise
    App.where(slug: "fundraise").last
  end

  private
  def page_creation(name:,title:,content:, destination:)
    Page.create!(name: name, title: title, content: content, destination: destination, app_id: self.id)
  end
end
