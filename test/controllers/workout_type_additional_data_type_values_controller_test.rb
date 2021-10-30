require "test_helper"

class WorkoutTypeAdditionalDataTypeValuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout_type_additional_data_type_value = workout_type_additional_data_type_values(:one)
  end

  test "should get index" do
    get workout_type_additional_data_type_values_url
    assert_response :success
  end

  test "should get new" do
    get new_workout_type_additional_data_type_value_url
    assert_response :success
  end

  test "should create workout_type_additional_data_type_value" do
    assert_difference('WorkoutTypeAdditionalDataTypeValue.count') do
      post workout_type_additional_data_type_values_url, params: { workout_type_additional_data_type_value: { user_id: @workout_type_additional_data_type_value.user_id, workout_id: @workout_type_additional_data_type_value.workout_id, workout_type_additional_data_type_id: @workout_type_additional_data_type_value.workout_type_additional_data_type_id, workout_type_additional_data_type_option_id: @workout_type_additional_data_type_value.workout_type_additional_data_type_option_id } }
    end

    assert_redirected_to workout_type_additional_data_type_value_url(WorkoutTypeAdditionalDataTypeValue.last)
  end

  test "should show workout_type_additional_data_type_value" do
    get workout_type_additional_data_type_value_url(@workout_type_additional_data_type_value)
    assert_response :success
  end

  test "should get edit" do
    get edit_workout_type_additional_data_type_value_url(@workout_type_additional_data_type_value)
    assert_response :success
  end

  test "should update workout_type_additional_data_type_value" do
    patch workout_type_additional_data_type_value_url(@workout_type_additional_data_type_value), params: { workout_type_additional_data_type_value: { user_id: @workout_type_additional_data_type_value.user_id, workout_id: @workout_type_additional_data_type_value.workout_id, workout_type_additional_data_type_id: @workout_type_additional_data_type_value.workout_type_additional_data_type_id, workout_type_additional_data_type_option_id: @workout_type_additional_data_type_value.workout_type_additional_data_type_option_id } }
    assert_redirected_to workout_type_additional_data_type_value_url(@workout_type_additional_data_type_value)
  end

  test "should destroy workout_type_additional_data_type_value" do
    assert_difference('WorkoutTypeAdditionalDataTypeValue.count', -1) do
      delete workout_type_additional_data_type_value_url(@workout_type_additional_data_type_value)
    end

    assert_redirected_to workout_type_additional_data_type_values_url
  end
end
