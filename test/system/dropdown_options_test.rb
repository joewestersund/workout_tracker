=begin
require "application_system_test_case"

class WorkoutTypeDropdownOptionsTest < ApplicationSystemTestCase
  setup do
    @workout_type_dropdown_option = workout_type_dropdown_options(:one)
  end

  test "visiting the index" do
    visit workout_type_dropdown_options_url
    assert_selector "h1", text: "Workout Type Additional Data Type Options"
  end

  test "creating a Workout type additional data type option" do
    visit workout_type_dropdown_options_url
    click_on "New Workout Type Additional Data Type Option"

    fill_in "Name", with: @workout_type_dropdown_option.name
    fill_in "Order in list", with: @workout_type_dropdown_option.order_in_list
    fill_in "User", with: @workout_type_dropdown_option.user_id
    fill_in "Workout type additional data type", with: @workout_type_dropdown_option.workout_type_data_type_id
    click_on "Create Workout type additional data type option"

    assert_text "Workout type additional data type option was successfully created"
    click_on "Back"
  end

  test "updating a Workout type additional data type option" do
    visit workout_type_dropdown_options_url
    click_on "Edit", match: :first

    fill_in "Name", with: @workout_type_dropdown_option.name
    fill_in "Order in list", with: @workout_type_dropdown_option.order_in_list
    fill_in "User", with: @workout_type_dropdown_option.user_id
    fill_in "Workout type additional data type", with: @workout_type_dropdown_option.workout_type_data_type_id
    click_on "Update Workout type additional data type option"

    assert_text "Workout type additional data type option was successfully updated"
    click_on "Back"
  end

  test "destroying a Workout type additional data type option" do
    visit workout_type_dropdown_options_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Workout type additional data type option was successfully destroyed"
  end
end
=end
