require "test_helper"

class RoutesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout_type = workout_types(:running)
    @route = routes(:bluff)
    sign_in_as users(:one)
  end

  test "should get index" do
    get routes_default_url
    assert_response :success
  end

  test "should get new" do
    get new_workout_type_route_path(@workout_type)
    assert_response :success
  end

  test "should create route" do
    assert_difference('Route.count') do
      post workout_type_routes_url(@workout_type), params: { route: { name: "#{@route.name}2", active: true } }
    end

    assert_redirected_to workout_type_routes_url(@workout_type)
  end

  test "should get edit" do
    get edit_route_url(@route)
    assert_response :success
  end

  test "should update route" do
    patch route_url(@route), params: { route: { name: @route.name, active: true } }
    assert_redirected_to workout_type_routes_url(@workout_type)
  end

  test "should destroy route" do
    assert_difference('Route.count', -1) do
      delete route_url(@route)
    end

    assert_redirected_to workout_type_routes_url(@workout_type)
  end
end
