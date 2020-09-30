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

ActiveRecord::Schema.define(version: 2019_11_29_124050) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "allergen_translations", force: :cascade do |t|
    t.integer "allergen_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["allergen_id"], name: "index_allergen_translations_on_allergen_id"
    t.index ["locale"], name: "index_allergen_translations_on_locale"
  end

  create_table "allergens", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "app_id"
    t.index ["app_id"], name: "index_allergens_on_app_id"
  end

  create_table "allergens_recipes", id: false, force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.integer "allergen_id", null: false
    t.index ["recipe_id", "allergen_id"], name: "index_allergens_recipes_on_recipe_id_and_allergen_id"
  end

  create_table "apps", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.integer "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_apps_on_plan_id"
    t.index ["slug"], name: "index_apps_on_slug", unique: true
  end

  create_table "autosaves", force: :cascade do |t|
    t.string "form"
    t.json "payload"
    t.integer "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_autosaves_on_app_id"
  end

  create_table "chef_translations", force: :cascade do |t|
    t.integer "chef_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "my_bio"
    t.index ["chef_id"], name: "index_chef_translations_on_chef_id"
    t.index ["locale"], name: "index_chef_translations_on_locale"
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

  create_table "ingredient_translations", force: :cascade do |t|
    t.integer "ingredient_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["ingredient_id"], name: "index_ingredient_translations_on_ingredient_id"
    t.index ["locale"], name: "index_ingredient_translations_on_locale"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name"
    t.integer "app_id"
    t.index ["app_id"], name: "index_ingredients_on_app_id"
  end

  create_table "likes", force: :cascade do |t|
    t.boolean "like"
    t.integer "recipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "app_id"
    t.index ["app_id"], name: "index_likes_on_app_id"
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

  create_table "page_preview_translations", force: :cascade do |t|
    t.integer "page_preview_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "content"
    t.index ["locale"], name: "index_page_preview_translations_on_locale"
    t.index ["page_preview_id"], name: "index_page_preview_translations_on_page_preview_id"
  end

  create_table "page_previews", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "content"
    t.string "destination"
    t.integer "page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_page_previews_on_page_id"
  end

  create_table "page_translations", force: :cascade do |t|
    t.integer "page_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "content"
    t.index ["locale"], name: "index_page_translations_on_locale"
    t.index ["page_id"], name: "index_page_translations_on_page_id"
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
    t.text "admin_name"
    t.integer "app_id"
    t.index ["app_id"], name: "index_pages_on_app_id"
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
    t.integer "recipe_id"
    t.string "user_type"
    t.string "subject"
    t.string "email"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_questions_on_user_id"
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

  create_table "recipe_translations", force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "description"
    t.text "summary"
    t.index ["locale"], name: "index_recipe_translations_on_locale"
    t.index ["recipe_id"], name: "index_recipe_translations_on_recipe_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "re_type"
    t.integer "app_id"
    t.integer "user_id"
    t.index ["app_id"], name: "index_reservations_on_app_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "style_translations", force: :cascade do |t|
    t.integer "style_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["locale"], name: "index_style_translations_on_locale"
    t.index ["style_id"], name: "index_style_translations_on_style_id"
  end

  create_table "styles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "app_id"
    t.index ["app_id"], name: "index_styles_on_app_id"
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
    t.integer "user_id"
    t.integer "email_sent_counter", default: 0
    t.integer "app_id"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.index ["app_id"], name: "index_users_on_app_id"
    t.index ["email", "app_id"], name: "index_users_on_email_and_app_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
