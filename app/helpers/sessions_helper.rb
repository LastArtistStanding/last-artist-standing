# frozen_string_literal: true

module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
    set_x_site_auth_code_cookie if ENV['X_AUTH_SECRET'].present?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete('user_id')
    clear_x_site_auth_code_cookie
    @current_user = nil
  end

  def x_auth_cookie
    cookie = cookies[:x_auth]
    return nil if cookie.nil?

    parts = cookie.split('/')
    return nil if parts.length != 2

    parts
  end

  def x_auth_code
    return nil if x_auth_cookie.nil?

    x_auth_cookie[1]
  end

  def x_auth_user
    return nil if x_auth_cookie.nil?

    x_auth_cookie[0]
  end

  def set_x_site_auth_code_cookie
    # The user id is required because the user's normal session cookie won't be sent with requests,
    # so we'd have no way of knowing which user we're authenticating otherwise.
    cookie_data = "#{current_user.id}/#{current_user.reset_x_site_auth_code}"

    # I'd prefer for this to be two separate cookies, or set in the usual way for cookies
    # (through `cookies[:x_auth]`) but afaict it is not possible to set `SameSite=None` that way.

    # `Secure` and `SameSite=None` are required for browsers to allow sending the cookie with CORS.
    # Unfortunately, this means you have to enable HTTPS
    # if you want to use this functionality in the development environment.
    response.add_header('Set-Cookie',
                        "x_auth=#{cookie_data}; Secure; SameSite=None; Path=/x_site_auth/")
  end

  def clear_x_site_auth_code_cookie
    # Deleting this cookie is somewhat more difficult because it is restricted to a specific path.
    response.add_header('Set-Cookie',
                        'x_auth=""; Secure; SameSite=None; Path=/x_site_auth/; Max-Age=-1')
    current_user.clear_x_site_auth_code
  end
end
