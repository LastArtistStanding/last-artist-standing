require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, xhr: true, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'shared/_error_messages'
    assert_template 'layouts/_signup_form'
  end
  
  
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, xhr: true, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_template 'users/create'
    assert is_logged_in?
  end
  
  
end