require "test_helper"

class WorkoutRoutesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout_route = workout_routes(:one)
  end

  test "should get index" do
    get workout_routes_url
    assert_response :success
  end

  test "should get new" do
    get new_workout_route_url
    assert_response :success
  end

  test "should create workout_route" do
    assert_difference('WorkoutRoute.count') do
      post workout_routes_url, params: { workout_route: { belongs_to: @workout_route.belongs_to, description: @workout_route.description, distance: @workout_route.distance, duration: @workout_route.duration, heart_rate: @workout_route.heart_rate, pace: @workout_route.pace, repetitions: @workout_route.repetitions } }
    end

    assert_redirected_to workout_route_url(WorkoutRoute.last)
  end

  test "should show workout_route" do
    get workout_route_url(@workout_route)
    assert_response :success
  end

  test "should get edit" do
    get edit_workout_route_url(@workout_route)
    assert_response :success
  end

  test "should update workout_route" do
    patch workout_route_url(@workout_route), params: { workout_route: { belongs_to: @workout_route.belongs_to, description: @workout_route.description, distance: @workout_route.distance, duration: @workout_route.duration, heart_rate: @workout_route.heart_rate, pace: @workout_route.pace, repetitions: @workout_route.repetitions } }
    assert_redirected_to workout_route_url(@workout_route)
  end

  test "should destroy workout_route" do
    assert_difference('WorkoutRoute.count', -1) do
      delete workout_route_url(@workout_route)
    end

    assert_redirected_to workout_routes_url
  end
end
