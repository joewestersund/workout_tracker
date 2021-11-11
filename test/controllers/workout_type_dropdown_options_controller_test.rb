require "test_helper"

class WorkoutTypeDropdownOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout_type_dropdown_option = workout_type_dropdown_options(:one)
  end

  test "should get index" do
    get workout_type_dropdown_options_url
    assert_response :success
  end

  test "should get new" do
    get new_workout_type_dropdown_option_url
    assert_response :success
  end

  test "should create workout_type_dropdown_option" do
    assert_difference('WorkoutTypeDropdownOption.count') do
      post workout_type_dropdown_options_url, params: { workout_type_dropdown_option: { name: @workout_type_dropdown_option.name, order_in_list: @workout_type_dropdown_option.order_in_list, user_id: @workout_type_dropdown_option.user_id, workout_type_data_type_id: @workout_type_dropdown_option.workout_type_data_type_id } }
    end

    assert_redirected_to workout_type_dropdown_option_url(WorkoutTypeDropdownOption.last)
  end

  test "should show workout_type_dropdown_option" do
    get workout_type_dropdown_option_url(@workout_type_dropdown_option)
    assert_response :success
  end

  test "should get edit" do
    get edit_workout_type_dropdown_option_url(@workout_type_dropdown_option)
    assert_response :success
  end

  test "should update workout_type_dropdown_option" do
    patch workout_type_dropdown_option_url(@workout_type_dropdown_option), params: { workout_type_dropdown_option: { name: @workout_type_dropdown_option.name, order_in_list: @workout_type_dropdown_option.order_in_list, user_id: @workout_type_dropdown_option.user_id, workout_type_data_type_id: @workout_type_dropdown_option.workout_type_data_type_id } }
    assert_redirected_to workout_type_dropdown_option_url(@workout_type_dropdown_option)
  end

  test "should destroy workout_type_dropdown_option" do
    assert_difference('WorkoutTypeDropdownOption.count', -1) do
      delete workout_type_dropdown_option_url(@workout_type_dropdown_option)
    end

    assert_redirected_to workout_type_dropdown_options_url
  end
end
