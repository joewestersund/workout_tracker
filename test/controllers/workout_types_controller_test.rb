require "test_helper"

class WorkoutTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout_type = workout_types(:one)
  end

  test "should get index" do
    get workout_types_url
    assert_response :success
  end

  test "should get new" do
    get new_workout_type_url
    assert_response :success
  end

  test "should create workout_type" do
    assert_difference('WorkoutType.count') do
      post workout_types_url, params: { workout_type: { name: @workout_type.name, order_in_list: @workout_type.order_in_list } }
    end

    assert_redirected_to workout_type_url(WorkoutType.last)
  end

  test "should show workout_type" do
    get workout_type_url(@workout_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_workout_type_url(@workout_type)
    assert_response :success
  end

  test "should update workout_type" do
    patch workout_type_url(@workout_type), params: { workout_type: { name: @workout_type.name, order_in_list: @workout_type.order_in_list } }
    assert_redirected_to workout_type_url(@workout_type)
  end

  test "should destroy workout_type" do
    assert_difference('WorkoutType.count', -1) do
      delete workout_type_url(@workout_type)
    end

    assert_redirected_to workout_types_url
  end
end
