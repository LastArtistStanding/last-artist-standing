require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  # post users_path, params: { user: { name: "name", email: "g@g.com", password: "password", password_confirmation: "password" } }

  test "no field should be missing" do
    get signup_path
    assert_no_difference 'User.count' do

      post users_path, params: { user: { name: "", email: "g@g.com", password: "password", password_confirmation: "password" } }
      post users_path, params: { user: { name: "name", email: "", password: "password", password_confirmation: "password" } }
      post users_path, params: { user: { name: "name", email: "g@g.com", password: "", password_confirmation: "password" } }
      post users_path, params: { user: { name: "name", email: "g@g.com", password: "password", password_confirmation: "" } }

    end
    assert_template 'layouts/_signup_form'
    assert_template 'users/create'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do

      post users_path, params: { user: { name: "name", email: "g@g.com", password: "password", password_confirmation: "password" } }

    end
    assert_template 'users/create'
    assert is_logged_in?
  end

  test "requires unique name and email fields" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "name", email: "g@g.com", password: "password", password_confirmation: "password" } }
      follow_redirect!
      assert_template 'users/show'
      get signup_path
      post users_path, params: { user: { name: "name", email: "gg@g.com", password: "password", password_confirmation: "password" } }
      post users_path, params: { user: { name: "name1", email: "g@g.com", password: "password", password_confirmation: "password" } }
    end
    assert_template 'users/new'
  end


end
