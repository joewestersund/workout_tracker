require "application_system_test_case"
require "test_helper"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "creating a User" do
    visit root_url
    assert_text "Sign in"
    click_on "Sign up now"
    assert_text "Sign Up"

    new_user_email = "test_user145@test2.com"

    fill_in "Name", with: "#{@user.name}2"
    fill_in "Email", with: new_user_email
    select @user.time_zone, from: "Time zone"
    click_on "Sign me up"

    assert_text "We've sent an email to you at"
    assert_text "Please use the link in that email to set your password and activate your account."

    u = User.find_by(email: new_user_email)
    visit "#{activate_account_url}/#{u.reset_password_token}"

    test_pw = "password1234"
    fill_in "Password" , with: test_pw
    fill_in "Password confirmation" , with: test_pw

    click_on "Submit"

    assert_text "Welcome to Log My Workout!"
  end

end
