require "application_system_test_case"

class WorkoutTypesTest < ApplicationSystemTestCase
  setup do
    @workout_type = workout_types(:one)
  end

  test "visiting the index" do
    visit workout_types_url
    assert_selector "h1", text: "Workout Types"
  end

  test "creating a Workout type" do
    visit workout_types_url
    click_on "New Workout Type"

    fill_in "Name", with: @workout_type.name
    fill_in "Order in list", with: @workout_type.order_in_list
    click_on "Create Workout type"

    assert_text "Workout type was successfully created"
    click_on "Back"
  end

  test "updating a Workout type" do
    visit workout_types_url
    click_on "Edit", match: :first

    fill_in "Name", with: @workout_type.name
    fill_in "Order in list", with: @workout_type.order_in_list
    click_on "Update Workout type"

    assert_text "Workout type was successfully updated"
    click_on "Back"
  end

  test "destroying a Workout type" do
    visit workout_types_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Workout type was successfully destroyed"
  end
end
