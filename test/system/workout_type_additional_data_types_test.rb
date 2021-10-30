require "application_system_test_case"

class WorkoutTypeAdditionalDataTypesTest < ApplicationSystemTestCase
  setup do
    @workout_type_additional_data_type = workout_type_additional_data_types(:one)
  end

  test "visiting the index" do
    visit workout_type_additional_data_types_url
    assert_selector "h1", text: "Workout Type Additional Data Types"
  end

  test "creating a Workout type additional data type" do
    visit workout_type_additional_data_types_url
    click_on "New Workout Type Additional Data Type"

    fill_in "Data type name", with: @workout_type_additional_data_type.data_type_name
    fill_in "Order in list", with: @workout_type_additional_data_type.order_in_list
    fill_in "User", with: @workout_type_additional_data_type.user_id
    fill_in "Workout type", with: @workout_type_additional_data_type.workout_type_id
    click_on "Create Workout type additional data type"

    assert_text "Workout type additional data type was successfully created"
    click_on "Back"
  end

  test "updating a Workout type additional data type" do
    visit workout_type_additional_data_types_url
    click_on "Edit", match: :first

    fill_in "Data type name", with: @workout_type_additional_data_type.data_type_name
    fill_in "Order in list", with: @workout_type_additional_data_type.order_in_list
    fill_in "User", with: @workout_type_additional_data_type.user_id
    fill_in "Workout type", with: @workout_type_additional_data_type.workout_type_id
    click_on "Update Workout type additional data type"

    assert_text "Workout type additional data type was successfully updated"
    click_on "Back"
  end

  test "destroying a Workout type additional data type" do
    visit workout_type_additional_data_types_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Workout type additional data type was successfully destroyed"
  end
end
