require "test_helper"

class DefaultDataPointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @default_data_point = default_data_points(:one)
  end

  test "should get index" do
    get default_data_points_url
    assert_response :success
  end

  test "should get new" do
    get new_default_data_point_url
    assert_response :success
  end

  test "should create default_data_point" do
    assert_difference('DefaultDataPoint.count') do
      post default_data_points_url, params: { default_data_point: {  } }
    end

    assert_redirected_to default_data_point_url(DefaultDataPoint.last)
  end

  test "should show default_data_point" do
    get default_data_point_url(@default_data_point)
    assert_response :success
  end

  test "should get edit" do
    get edit_default_data_point_url(@default_data_point)
    assert_response :success
  end

  test "should update default_data_point" do
    patch default_data_point_url(@default_data_point), params: { default_data_point: {  } }
    assert_redirected_to default_data_point_url(@default_data_point)
  end

  test "should destroy default_data_point" do
    assert_difference('DefaultDataPoint.count', -1) do
      delete default_data_point_url(@default_data_point)
    end

    assert_redirected_to default_data_points_url
  end
end
