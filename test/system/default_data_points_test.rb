require "application_system_test_case"

class DefaultDataPointsTest < ApplicationSystemTestCase
  setup do
    @default_data_point = default_data_points(:one)
  end

  test "visiting the index" do
    visit default_data_points_url
    assert_selector "h1", text: "Default Data Points"
  end

  test "creating a Default data point" do
    visit default_data_points_url
    click_on "New Default Data Point"

    click_on "Create Default data point"

    assert_text "Default data point was successfully created"
    click_on "Back"
  end

  test "updating a Default data point" do
    visit default_data_points_url
    click_on "Edit", match: :first

    click_on "Update Default data point"

    assert_text "Default data point was successfully updated"
    click_on "Back"
  end

  test "destroying a Default data point" do
    visit default_data_points_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Default data point was successfully destroyed"
  end
end
