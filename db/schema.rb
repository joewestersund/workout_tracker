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

ActiveRecord::Schema.define(version: 2022_01_10_063007) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "data_points", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "workout_route_id"
    t.bigint "data_type_id"
    t.bigint "dropdown_option_id"
    t.text "text_value"
    t.decimal "decimal_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_type_id"], name: "index_adtv_on_adt"
    t.index ["dropdown_option_id"], name: "index_adtv_on_adto"
    t.index ["user_id"], name: "index_data_points_on_user_id"
    t.index ["workout_route_id"], name: "index_data_points_on_workout_route_id"
  end

  create_table "data_types", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "workout_type_id"
    t.string "name"
    t.string "field_type"
    t.string "units"
    t.text "description"
    t.integer "order_in_list"
    t.boolean "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "workout_type_id", "order_in_list"], name: "index_adt_on_user_and_workout_type_and_order"
    t.index ["user_id"], name: "index_data_types_on_user_id"
    t.index ["workout_type_id"], name: "index_data_types_on_workout_type_id"
  end

  create_table "default_data_points", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "route_id"
    t.bigint "data_type_id"
    t.bigint "dropdown_option_id"
    t.text "text_value"
    t.decimal "decimal_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_type_id"], name: "index_ddp_on_dt"
    t.index ["dropdown_option_id"], name: "index_ddp_on_do"
    t.index ["route_id"], name: "index_default_data_points_on_route_id"
    t.index ["user_id"], name: "index_default_data_points_on_user_id"
  end

  create_table "dropdown_options", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "data_type_id"
    t.string "name"
    t.integer "order_in_list"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_type_id"], name: "index_dropdown_options_on_data_type_id"
    t.index ["user_id", "data_type_id", "order_in_list"], name: "index_adto_on_user_and_adt_and_order"
    t.index ["user_id"], name: "index_dropdown_options_on_user_id"
  end

  create_table "routes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "workout_type_id"
    t.string "name"
    t.text "description"
    t.integer "order_in_list"
    t.boolean "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "workout_type_id", "order_in_list"], name: "index_routes_on_user_id_and_workout_type_id_and_order_in_list"
    t.index ["user_id"], name: "index_routes_on_user_id"
    t.index ["workout_type_id"], name: "index_routes_on_workout_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.string "remember_token"
    t.string "reset_password_token"
    t.datetime "password_reset_sent_at"
    t.string "time_zone"
    t.boolean "activated"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "workout_routes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "workout_id"
    t.bigint "route_id"
    t.integer "repetitions"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["route_id"], name: "index_workout_routes_on_route_id"
    t.index ["user_id"], name: "index_workout_routes_on_user_id"
    t.index ["workout_id"], name: "index_workout_routes_on_workout_id"
  end

  create_table "workout_types", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.integer "order_in_list"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "order_in_list"], name: "index_workout_types_on_user_id_and_order_in_list"
    t.index ["user_id"], name: "index_workout_types_on_user_id"
  end

  create_table "workouts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "workout_type_id"
    t.date "workout_date"
    t.integer "year"
    t.integer "month"
    t.integer "week"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "day"
    t.integer "week_year"
    t.index ["user_id", "week_year", "week"], name: "index_workouts_on_user_id_and_week_year_and_week", order: { week_year: :desc, week: :desc }
    t.index ["user_id", "workout_date"], name: "index_workouts_on_user_id_and_workout_date", order: { workout_date: :desc }
    t.index ["user_id", "year", "month", "day"], name: "index_workouts_on_user_id_and_year_and_month_and_day", order: { year: :desc, month: :desc, day: :desc }
    t.index ["user_id"], name: "index_workouts_on_user_id"
    t.index ["workout_type_id"], name: "index_workouts_on_workout_type_id"
  end

end
