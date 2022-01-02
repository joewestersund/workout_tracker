require "test_helper"

class DefaultDataPointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @default_data_point = default_data_points(:one)
    @route = routes(:bluff)
    @data_type = data_types(:pace)
    sign_in_as users(:one)
  end

  test "should get index" do
    get route_default_data_points_url(@route)
    assert_response :success
  end

  test "should get new" do
    get new_route_default_data_point_url(@route, data_type_id: @data_type.id)
    assert_response :success
  end

  test "should create default_data_point" do
    # create new route that doesn't have this default data point yet
    assert_difference('Route.count') do
      post workout_type_routes_url(@route.workout_type), params: { route: { name: "#{@route.name}2", active: true } }
    end

    new_route = Route.last

    assert_difference('DefaultDataPoint.count') do
      post route_default_data_points_url(new_route), params: { default_data_point: { data_type_id: @data_type.id, decimal_value: 6 } }
    end

    assert_redirected_to route_default_data_points_url(new_route)
  end

  test "should get edit" do
    get edit_default_data_point_url(@default_data_point)
    assert_response :success
  end

  test "should update default_data_point" do
    patch default_data_point_url(@default_data_point), params: { default_data_point: { data_type: @default_data_point.data_type, decimal_value: 6.5 } }
    assert_redirected_to route_default_data_points_url(@route)
  end

  test "should destroy default_data_point" do
    assert_difference('DefaultDataPoint.count', -1) do
      delete default_data_point_url(@default_data_point)
    end

    assert_redirected_to route_default_data_points_url(@route)
  end
end
