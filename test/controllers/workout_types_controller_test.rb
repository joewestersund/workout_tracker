require "test_helper"

class WorkoutTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout_type = workout_types(:running)
    @workout_type2 = workout_types(:bouldering)
    sign_in_as users(:one)
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
      post workout_types_url, params: { workout_type: { name: "#{@workout_type.name}2"  } }
    end

    assert_redirected_to workout_types_url
  end

  test "should get edit" do
    get edit_workout_type_url(@workout_type)
    assert_response :success
  end

  test "should update workout_type" do
    patch workout_type_url(@workout_type), params: { workout_type: { name: @workout_type.name, order_in_list: @workout_type.order_in_list } }

    assert_redirected_to workout_types_url
  end

  test "should destroy workout_type if has no data" do
    # create new workout type so we know it has no data
    assert_difference('WorkoutType.count') do
      post workout_types_url, params: { workout_type: { name: "#{@workout_type.name}2"  } }
    end

    new_workout_type = WorkoutType.last
    assert_difference('WorkoutType.count', -1) do
      delete workout_type_url(new_workout_type)
    end

    assert_redirected_to workout_types_url
  end

  test "should destroy workout_type even if it has data" do
    assert_difference('WorkoutType.count', -1) do
      delete workout_type_url(@workout_type)
    end

    assert_redirected_to workout_types_url
  end

  test "should move up" do
    two = @workout_type2
    initial_position = two.order_in_list
    post move_workout_type_up_url(two)
    two.reload
    assert_equal(two.order_in_list, initial_position - 1)
    assert_redirected_to workout_types_url
  end

  test "should move down" do
    one = @workout_type
    initial_position = one.order_in_list
    post move_workout_type_down_url(one)
    one.reload
    assert_equal(one.order_in_list, initial_position + 1)
    assert_redirected_to workout_types_url
  end

  test "shouldn't move first one up" do
    one = @workout_type
    initial_position = one.order_in_list
    post move_workout_type_up_url(one)
    one.reload
    assert_equal(one.order_in_list, initial_position)
    assert_redirected_to workout_types_url
  end

  test "shouldn't move last one down" do
    last = @workout_type2
    initial_position = last.order_in_list
    post move_workout_type_down_url(last)
    last.reload
    assert_equal(last.order_in_list, initial_position)
    assert_redirected_to workout_types_url
  end
end
