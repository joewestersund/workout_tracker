require "test_helper"

class DataTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout_type = workout_types(:running)
    @data_type = data_types(:pace)
    sign_in_as users(:one)
  end

  test "should get index" do
    get workout_type_data_types_url(@workout_type)
    assert_response :success
  end

  test "should get new" do
    get new_workout_type_data_type_url(@workout_type)
    assert_response :success
  end

  test "should create data_type" do
    assert_difference('DataType.count') do
      post workout_type_data_types_url(@workout_type), params: { data_type: { name: "#{@data_type.name}2" } }
    end

    assert_redirected_to workout_type_data_types_url(@workout_type)
  end

  test "should get edit" do
    get edit_data_type_url(@data_type)
    assert_response :success
  end

  test "should update data_type" do
    patch data_type_url(@data_type), params: { data_type: { name: @data_type.name } }
    assert_redirected_to workout_type_data_types_url(@workout_type)
  end

  test "should destroy data_type" do
    assert_difference('DataType.count', -1) do
      delete data_type_url(@data_type)
    end

    assert_redirected_to workout_type_data_types_url(@workout_type)
  end
end
