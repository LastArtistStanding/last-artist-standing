# frozen_string_literal: true

require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'login with invalid information' do
    get login_path
    assert_redirected_to '/'
    post login_path, xhr: true, params: { session: { email: '', password: '' } }
    assert_template 'layouts/_login_form'
  end

  test 'login with valid information followed by logout' do
    # FIXME: Set up factories so that this test can be re-enabled.
    #   Currently, it fails because there is no seasonal challenge set.

=begin
    get login_path
    post login_path, xhr: true, params: { session: { email: @user.email,
                                                     password: 'password' } }
    assert_response :success
    get '/'
    assert_select 'a[href=?]', '#login-modal', count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
    delete logout_path
    assert_not logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select 'a[href=?]', '#login-modal'
    assert_select 'a[href=?]', logout_path,      count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
=end
  end
end
