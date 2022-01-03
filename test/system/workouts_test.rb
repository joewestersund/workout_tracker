require "application_system_test_case"
require "test_helper"

class WorkoutsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    #sign in
    visit root_url
    assert_text "Sign in"
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_on "Sign in"

    assert_text "Workouts"
    assert_text "New Workout"

    @workout = workouts(:one)
  end

  test "visiting the index" do
    visit workouts_url
    assert_selector "h1", text: "Workouts"
  end

  test "creating a Workout" do
    visit workouts_url
    click_link "New Workout", match: :first

    #fill_in "Workout date", with: @workout.workout_date
    #select @workout.workout_type.name, from: "Workout type"
    fill_in "Repetitions", with: 2, match: :first
    click_button "Create Workout"

    assert_text "Workout was successfully created"
  end

  test "updating a Workout" do
    visit workouts_url
    click_link "Edit", match: :first

    #fill_in "Workout date", with: @workout.workout_date
    #select @workout.workout_type.name, from: "Workout type"
    fill_in "Repetitions", with: 3, match: :first
    click_button "Update Workout"

    assert_text "Workout was successfully updated"
  end

  test "destroying a Workout" do
    visit workouts_url
    page.accept_confirm do
      click_link "Delete", match: :first
    end

    assert_text "Workout was successfully destroyed"
  end
end
