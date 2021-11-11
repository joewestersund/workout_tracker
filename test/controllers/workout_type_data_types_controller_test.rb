require "test_helper"

class WorkoutTypeDataTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout_type_data_type = workout_type_data_types(:one)
  end

  test "should get index" do
    get workout_type_data_types_url
    assert_response :success
  end

  test "should get new" do
    get new_workout_type_data_type_url
    assert_response :success
  end

  test "should create workout_type_data_type" do
    assert_difference('WorkoutTypeDataType.count') do
      post workout_type_data_types_url, params: { workout_type_data_type: { data_type_name: @workout_type_data_type.data_type_name, order_in_list: @workout_type_data_type.order_in_list, user_id: @workout_type_data_type.user_id, workout_type_id: @workout_type_data_type.workout_type_id } }
    end

    assert_redirected_to workout_type_data_type_url(WorkoutTypeDataType.last)
  end

  test "should show workout_type_data_type" do
    get workout_type_data_type_url(@workout_type_data_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_workout_type_data_type_url(@workout_type_data_type)
    assert_response :success
  end

  test "should update workout_type_data_type" do
    patch workout_type_data_type_url(@workout_type_data_type), params: { workout_type_data_type: { data_type_name: @workout_type_data_type.data_type_name, order_in_list: @workout_type_data_type.order_in_list, user_id: @workout_type_data_type.user_id, workout_type_id: @workout_type_data_type.workout_type_id } }
    assert_redirected_to workout_type_data_type_url(@workout_type_data_type)
  end

  test "should destroy workout_type_data_type" do
    assert_difference('WorkoutTypeDataType.count', -1) do
      delete workout_type_data_type_url(@workout_type_data_type)
    end

    assert_redirected_to workout_type_data_types_url
  end
end
