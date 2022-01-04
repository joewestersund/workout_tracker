require "test_helper"

class DropdownOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dropdown_option = dropdown_options(:one)
    @dropdown_option2 = dropdown_options(:two)
    @dropdown_data_type = data_types(:running_surface)
    sign_in_as users(:one)
  end

  test "should get index" do
    get data_type_dropdown_options_url(@dropdown_data_type)
    assert_response :success
  end

  test "should get new" do
    get new_data_type_dropdown_option_url(@dropdown_data_type)
    assert_response :success
  end

  test "should create dropdown_option" do
    assert_difference('DropdownOption.count') do
      post data_type_dropdown_options_url(@dropdown_data_type), params: { dropdown_option: { name: "#{@dropdown_option.name}2" } }
    end

    assert_redirected_to data_type_dropdown_options_url(@dropdown_data_type)
  end

  test "should get edit" do
    get edit_dropdown_option_url(@dropdown_option)
    assert_response :success
  end

  test "should update dropdown_option" do
    patch dropdown_option_url(@dropdown_option), params: { dropdown_option: { name: @dropdown_option.name } }
    assert_redirected_to data_type_dropdown_options_url(@dropdown_data_type)
  end

  test "should destroy dropdown_option" do
    # create a new dropdown option so that we know there aren't any data points that use it.
    assert_difference('DropdownOption.count') do
      post data_type_dropdown_options_url(@dropdown_data_type), params: { dropdown_option: { name: "#{@dropdown_option.name}2" } }
    end

    new_dropdown_option = DropdownOption.last
    # can delete
    assert_difference('DropdownOption.count', -1) do
      delete dropdown_option_url(new_dropdown_option)
    end

    assert_redirected_to data_type_dropdown_options_url(@dropdown_data_type)

  end

  test "shouldn't destroy dropdown_option if there are data points that use it" do
    # can't delete if there are data points for this dropdown option
    assert_difference('DropdownOption.count', 0) do
      delete dropdown_option_url(@dropdown_option)
    end

    assert_redirected_to data_type_dropdown_options_url(@dropdown_data_type)

  end

  test "should move up" do
    two = @dropdown_option2
    initial_position = two.order_in_list
    post move_dropdown_option_up_url(two)
    two.reload
    assert_equal(two.order_in_list, initial_position - 1)
    assert_redirected_to data_type_dropdown_options_url(@dropdown_data_type)
  end

  test "should move down" do
    one = @dropdown_option
    initial_position = one.order_in_list
    post move_dropdown_option_down_url(one)
    one.reload
    assert_equal(one.order_in_list, initial_position + 1)
    assert_redirected_to data_type_dropdown_options_url(@dropdown_data_type)
  end

  test "shouldn't move first one up" do
    one = @dropdown_option
    initial_position = one.order_in_list
    post move_dropdown_option_up_url(one)
    one.reload
    assert_equal(one.order_in_list, initial_position)
    assert_redirected_to data_type_dropdown_options_url(@dropdown_data_type)
  end

  test "shouldn't move last one down" do
    last = @dropdown_option2
    initial_position = last.order_in_list
    post move_dropdown_option_down_url(last)
    last.reload
    assert_equal(last.order_in_list, initial_position)
    assert_redirected_to data_type_dropdown_options_url(@dropdown_data_type)
  end
end
