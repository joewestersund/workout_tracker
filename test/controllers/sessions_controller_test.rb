require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "should log user out" do
    delete signout_url

    assert_redirected_to root_url

    # check that logged out

    get workouts_url

    assert_redirected_to signin_url

  end

end
