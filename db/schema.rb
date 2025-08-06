# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_06_134913) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_setups", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "domain_name"
    t.string "package_type"
    t.string "support_option"
    t.string "payment_status", default: "pending"
    t.string "stripe_payment_intent_id"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_account_setups_on_user_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "name"
    t.text "html_content"
    t.text "css_content"
    t.text "js_content"
    t.text "editable_fields"
    t.text "component_type"
    t.text "template_patterns"
    t.boolean "global", default: false
    t.text "field_types"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "theme_page_components", force: :cascade do |t|
    t.bigint "theme_page_id", null: false
    t.bigint "component_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_theme_page_components_on_component_id"
    t.index ["theme_page_id"], name: "index_theme_page_components_on_theme_page_id"
  end

  create_table "theme_pages", force: :cascade do |t|
    t.bigint "theme_id", null: false
    t.string "page_type"
    t.text "component_order"
    t.text "package", default: "Bespoke"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["theme_id"], name: "index_theme_pages_on_theme_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 1
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "website_services", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "features"
    t.string "icon"
    t.string "slug"
    t.index ["user_id"], name: "index_website_services_on_user_id"
  end

  create_table "websites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "theme_id", null: false
    t.string "name"
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theme_id"], name: "index_websites_on_theme_id"
    t.index ["user_id"], name: "index_websites_on_user_id"
  end

  create_table "websites_customisations", force: :cascade do |t|
    t.bigint "website_id", null: false
    t.bigint "component_id", null: false
    t.bigint "theme_page_id", null: false
    t.string "field_name"
    t.string "field_value"
    t.string "field_styling"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_websites_customisations_on_component_id"
    t.index ["theme_page_id"], name: "index_websites_customisations_on_theme_page_id"
    t.index ["website_id"], name: "index_websites_customisations_on_website_id"
  end

  add_foreign_key "account_setups", "users"
  add_foreign_key "theme_page_components", "components"
  add_foreign_key "theme_page_components", "theme_pages"
  add_foreign_key "theme_pages", "themes"
  add_foreign_key "website_services", "users"
  add_foreign_key "websites", "themes"
  add_foreign_key "websites", "users"
  add_foreign_key "websites_customisations", "components"
  add_foreign_key "websites_customisations", "theme_pages"
  add_foreign_key "websites_customisations", "websites"
end
