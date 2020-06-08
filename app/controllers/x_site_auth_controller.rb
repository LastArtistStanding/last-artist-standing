# frozen_string_literal: true

require 'jwt'

# Allows log-in to other sites (i.e. the forums) with your DAD account.
class XSiteAuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[sign]
  before_action :set_no_cache

  # Does the user have an x-auth cookie set?
  # Other sites snooping on whether a user is logged in is prevented by CORS.
  def auto_login_available
    render plain: (!x_auth_cookie.nil?).to_s
  end

  # Log in to this site, and get redirected back to the DAD zone with your new auth code.
  def login
    # `return_to` is a parameter rather than using the referer header
    # so that disabling referers (which I will likely do globally for the DAD forums)
    # won't break cross-site login.
    unless params[:return_to]
      flash[:danger] = "You didn't specify which page to return to!"
      # Alternatively, it would be equally valid to kick back users to the home page.
      # I don't suppose it matters that much, because these cases are unlikely to ever be hit,
      # and render_unauthorized makes debugging easier than a redirect does.
      render_unauthorized
      return
    end

    @return_to = URI(params[:return_to])

    # These checks aren't strictly necessary because removing them wouldn't cause a security bug
    # due to stuff like CORS settings, but they're still avoided to prevent client-side code bugs
    # (i.e. so that *my* code won't set the wrong return URL).
    unless @return_to.scheme == 'https'
      flash[:danger] =
        "HTTPS is required for cross-site authentication; #{@return_to} is not an HTTPS URL."
      render_unauthorized
      return
    end

    unless @return_to.host == ENV['X_AUTH_HOST']
      flash[:danger] =
        "You can't use your DAD account to log in to #{@return_to.host || 'no website at all'}!"
      render_unauthorized
      return
    end

    unless logged_in?
      render :login
      return
    end

    # Re-set the x-auth code in a cookie in case it was unset or incorrect for some reason.
    unless current_user.x_site_auth_code_correct?(x_auth_code) &&
           x_auth_user == current_user.id.to_s
      set_x_site_auth_code_cookie
    end

    redirect_to @return_to.to_s, status: 303
  end

  # Generate a signed JWT token that the user can use to prove who they are.
  def sign
    # Error codes are returned as plain text so that the client code can use them.
    # This page is intended to be accessed directly by a user.
    unless params[:code]
      render plain: 'You need to submit a code to sign!', status: :unprocessable_entity
      return
    end

    if x_auth_cookie.nil?
      # In this case, visiting `/x_site_auth/login` would also technically work,
      # but that's not something that I expect the user to have an intuition to know how to use.
      render plain: 'You do not have an x-auth cookie set.',
             status: :unauthorized
      return
    end

    user = User.find_by(id: x_auth_user)

    if user.nil?
      render plain: 'That user does not exist!', status: :unauthorized
      return
    end

    unless user.x_site_auth_code_correct?(x_auth_code)
      render plain: 'Your x-site auth code is incorrect.',
             status: :unauthorized
      return
    end

    payload = {
      code: params[:code],
      user: user.id,
      exp: (Time.now.utc + 30.seconds).to_i
    }
    render plain: JWT.encode(payload, ENV['X_AUTH_SECRET'], 'HS256')
  end
end
