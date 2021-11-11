require "test_helper"

class WorkoutTypeDataPointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout_type_data_point = workout_type_data_points(:one)
  end

  test "should get index" do
    get workout_type_data_points_url
    assert_response :success
  end

  test "should get new" do
    get new_workout_type_data_point_url
    assert_response :success
  end

  test "should create workout_type_data_point" do
    assert_difference('WorkoutTypeDataPoint.count') do
      post workout_type_data_points_url, params: { workout_type_data_point: { user_id: @workout_type_data_point.user_id, workout_id: @workout_type_data_point.workout_id, workout_type_data_type_id: @workout_type_data_point.workout_type_data_type_id, workout_type_dropdown_option_id: @workout_type_data_point.workout_type_dropdown_option_id } }
    end

    assert_redirected_to workout_type_data_point_url(WorkoutTypeDataPoint.last)
  end

  test "should show workout_type_data_point" do
    get workout_type_data_point_url(@workout_type_data_point)
    assert_response :success
  end

  test "should get edit" do
    get edit_workout_type_data_point_url(@workout_type_data_point)
    assert_response :success
  end

  test "should update workout_type_data_point" do
    patch workout_type_data_point_url(@workout_type_data_point), params: { workout_type_data_point: { user_id: @workout_type_data_point.user_id, workout_id: @workout_type_data_point.workout_id, workout_type_data_type_id: @workout_type_data_point.workout_type_data_type_id, workout_type_dropdown_option_id: @workout_type_data_point.workout_type_dropdown_option_id } }
    assert_redirected_to workout_type_data_point_url(@workout_type_data_point)
  end

  test "should destroy workout_type_data_point" do
    assert_difference('WorkoutTypeDataPoint.count', -1) do
      delete workout_type_data_point_url(@workout_type_data_point)
    end

    assert_redirected_to workout_type_data_points_url
  end
end
