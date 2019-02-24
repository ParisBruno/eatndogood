# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190224040610) do

  create_table "allergens", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "allergens_recipes", id: false, force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.integer "allergen_id", null: false
    t.index ["recipe_id", "allergen_id"], name: "index_allergens_recipes_on_recipe_id_and_allergen_id"
  end

  create_table "chefs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.integer "user_id"
    t.text "my_bio"
    t.string "chef_avatar_file_name"
    t.string "chef_avatar_content_type"
    t.integer "chef_avatar_file_size"
    t.datetime "chef_avatar_updated_at"
    t.integer "admin_id"
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string "data_uid", null: false
    t.string "data_name", null: false
    t.string "data_mime_type"
    t.integer "data_size"
    t.string "type", limit: 30
    t.integer "data_width"
    t.integer "data_height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "comments", force: :cascade do |t|
    t.text "description"
    t.integer "chef_id"
    t.integer "recipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "email_contents", force: :cascade do |t|
    t.string "subject"
    t.string "receiver"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.boolean "like"
    t.integer "user_id"
    t.integer "recipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mail_attachments", force: :cascade do |t|
    t.integer "email_content_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_attach_file_name"
    t.string "file_attach_content_type"
    t.integer "file_attach_file_size"
    t.datetime "file_attach_updated_at"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.integer "chef_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", force: :cascade do |t|
    t.string "name"
    t.text "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "destination"
    t.string "page_img_file_name"
    t.string "page_img_content_type"
    t.integer "page_img_file_size"
    t.datetime "page_img_updated_at"
    t.integer "user_id"
    t.text "admin_name"
  end

  create_table "plan_categories", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string "title"
    t.integer "chefs_limit"
    t.integer "guests_limit"
    t.integer "recipes_limit"
    t.integer "plan_category_id"
    t.decimal "yearly_cost"
    t.decimal "cost_per_user"
    t.bigint "no_of_chefs"
    t.string "status"
    t.text "guest"
    t.string "code"
    t.index ["title"], name: "index_plans_on_title"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipe_id"
    t.string "user_type"
    t.string "subject"
    t.string "email"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipe_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "recipe_id"
    t.string "img_type"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.integer "recipe_id"
    t.integer "ingredient_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chef_id"
    t.text "summary"
  end

  create_table "recipes_styles", id: false, force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.integer "style_id", null: false
    t.index ["recipe_id", "style_id"], name: "index_recipes_styles_on_recipe_id_and_style_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.string "full_name"
    t.string "phone_number"
    t.integer "number_people"
    t.date "ci_date"
    t.time "ci_time"
    t.text "notes"
    t.integer "recipe_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  create_table "styles", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_plans", force: :cascade do |t|
    t.integer "user_id"
    t.integer "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.boolean "chef"
    t.boolean "guest", default: true
    t.integer "chef_id"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "plan_id"
    t.integer "user_id"
    t.string "slug"
    t.integer "email_sent_counter", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["plan_id"], name: "index_users_on_plan_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

end
