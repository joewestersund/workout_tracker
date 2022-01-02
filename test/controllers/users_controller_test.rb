require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as users(:one)
  end

  test "should get edit" do
    get profile_edit_url
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { email: @user.email, name: @user.name, password_digest: @user.password_digest, password_reset_sent_at: @user.password_reset_sent_at, remember_token: @user.remember_token, reset_password_token: @user.reset_password_token, time_zone: @user.time_zone } }
    assert_redirected_to profile_edit_url
  end

end
