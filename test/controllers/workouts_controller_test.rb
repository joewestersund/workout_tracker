require "test_helper"

class WorkoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workout = workouts(:one)
    sign_in_as users(:one)
  end

  test "should get index" do
    get workouts_url
    assert_response :success
  end

  test "should get new" do
    get new_workout_url
    assert_response :success
  end

  test "should create workout" do
    assert_difference('Workout.count') do
      post workouts_url, params: { workout: { user_id: @workout.user_id, workout_date: @workout.workout_date, workout_type_id: @workout.workout_type_id } }
    end

    assert_redirected_to workouts_url
  end

  test "should get edit" do
    get edit_workout_url(@workout)
    assert_response :success
  end

  test "should update workout" do
    patch workout_url(@workout), params: { workout: { user_id: @workout.user_id, workout_date: @workout.workout_date, workout_type_id: @workout.workout_type_id } }
    assert_redirected_to workouts_url
  end

  test "should destroy workout" do
    assert_difference('Workout.count', -1) do
      delete workout_url(@workout)
    end

    assert_redirected_to workouts_url
  end
end
