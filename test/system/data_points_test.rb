=begin
require "application_system_test_case"

class WorkoutTypeDataPointsTest < ApplicationSystemTestCase
  setup do
    @workout_type_data_point = workout_type_data_points(:one)
  end

  test "visiting the index" do
    visit workout_type_data_points_url
    assert_selector "h1", text: "Workout Type Additional Data Type Values"
  end

  test "creating a Workout type additional data type value" do
    visit workout_type_data_points_url
    click_on "New Workout Type Additional Data Type Value"

    fill_in "User", with: @workout_type_data_point.user_id
    fill_in "Workout", with: @workout_type_data_point.workout_id
    fill_in "Workout type additional data type", with: @workout_type_data_point.workout_type_data_type_id
    fill_in "Workout type additional data type option", with: @workout_type_data_point.workout_type_dropdown_option_id
    click_on "Create Workout type additional data type value"

    assert_text "Workout type additional data type value was successfully created"
    click_on "Back"
  end

  test "updating a Workout type additional data type value" do
    visit workout_type_data_points_url
    click_on "Edit", match: :first

    fill_in "User", with: @workout_type_data_point.user_id
    fill_in "Workout", with: @workout_type_data_point.workout_id
    fill_in "Workout type additional data type", with: @workout_type_data_point.workout_type_data_type_id
    fill_in "Workout type additional data type option", with: @workout_type_data_point.workout_type_dropdown_option_id
    click_on "Update Workout type additional data type value"

    assert_text "Workout type additional data type value was successfully updated"
    click_on "Back"
  end

  test "destroying a Workout type additional data type value" do
    visit workout_type_data_points_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Workout type additional data type value was successfully destroyed"
  end
end
=end
