require "application_system_test_case"

class WorkoutRoutesTest < ApplicationSystemTestCase
  setup do
    @workout_route = workout_routes(:one)
  end

  test "visiting the index" do
    visit workout_routes_url
    assert_selector "h1", text: "Workout Routes"
  end

  test "creating a Workout route" do
    visit workout_routes_url
    click_on "New Workout Route"

    fill_in "Belongs to", with: @workout_route.belongs_to
    fill_in "Description", with: @workout_route.description
    fill_in "Distance", with: @workout_route.distance
    fill_in "Duration", with: @workout_route.duration
    fill_in "Heart rate", with: @workout_route.heart_rate
    fill_in "Pace", with: @workout_route.pace
    fill_in "Repetitions", with: @workout_route.repetitions
    click_on "Create Workout route"

    assert_text "Workout route was successfully created"
    click_on "Back"
  end

  test "updating a Workout route" do
    visit workout_routes_url
    click_on "Edit", match: :first

    fill_in "Belongs to", with: @workout_route.belongs_to
    fill_in "Description", with: @workout_route.description
    fill_in "Distance", with: @workout_route.distance
    fill_in "Duration", with: @workout_route.duration
    fill_in "Heart rate", with: @workout_route.heart_rate
    fill_in "Pace", with: @workout_route.pace
    fill_in "Repetitions", with: @workout_route.repetitions
    click_on "Update Workout route"

    assert_text "Workout route was successfully updated"
    click_on "Back"
  end

  test "destroying a Workout route" do
    visit workout_routes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Workout route was successfully destroyed"
  end
end
