require "application_system_test_case"

class RoutesTest < ApplicationSystemTestCase
  setup do
    @route = routes(:one)
  end

  test "visiting the index" do
    visit routes_url
    assert_selector "h1", text: "Routes"
  end

  test "creating a Route" do
    visit routes_url
    click_on "New Route"

    fill_in "Belongs to", with: @route.belongs_to
    fill_in "Distance", with: @route.distance
    fill_in "Name", with: @route.name
    fill_in "Order in list", with: @route.order_in_list
    click_on "Create Route"

    assert_text "Route was successfully created"
    click_on "Back"
  end

  test "updating a Route" do
    visit routes_url
    click_on "Edit", match: :first

    fill_in "Belongs to", with: @route.belongs_to
    fill_in "Distance", with: @route.distance
    fill_in "Name", with: @route.name
    fill_in "Order in list", with: @route.order_in_list
    click_on "Update Route"

    assert_text "Route was successfully updated"
    click_on "Back"
  end

  test "destroying a Route" do
    visit routes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Route was successfully destroyed"
  end
end
