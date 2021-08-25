# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :verify_domain, if: -> { Rails.env.production? && ENV['BLOCK_HEROKU'] == 'TRUE' }
  before_action :set_sentry_context
  before_action :record_user_session

  def render_unauthenticated
    # Technically, the HTTP response code intended for unauthenticated requests is `401`.
    # However, to use it, you must support HTTP's authentication mechanism, which we don't.
    render '/pages/unauthenticated', status: :forbidden
  end

  def render_unauthorized
    render '/pages/unauthorized', status: :forbidden
  end

  def render_unverified
    render '/pages/unverified', status: :forbidden
  end

  def render_not_found
    render file: "#{Rails.root}/public/404.html", status: :not_found
  end

  def render_hidden(message)
    render 'pages/hidden', locals: { message: message }, status: :forbidden
  end

  # Ensure that a user is logged in.
  # Actions which have visible effects for other users should use `ensure_authenticated` instead.
  def ensure_logged_in
    render_unauthenticated unless logged_in?
  end

  # Check that if a user is logged in and allowed to do most normal tasks.
  def ensure_authenticated
    if !logged_in?
      render_unauthenticated
    elsif !current_user.verified?
      render_unverified
    end
  end

  # Check that the logged-in user is authorized to modify this submission.
  def ensure_authorized(creator_id)
    render_unauthorized unless creator_id == current_user.id
  end

  def ensure_clearance(permission_level)
    render_unauthorized unless current_user&.has_clearance?(permission_level)
  end

  def ensure_moderator
    render_unauthorized unless current_user&.is_moderator || current_user&.is_admin
  end

  def ensure_unbanned
    latest_ban = SiteBan.find_by("'#{Time.now.utc}' < expiration AND user_id = #{current_user.id}")
    unless latest_ban.nil?
      render '/pages/banned', locals: { ban: latest_ban }, status: :forbidden
    end
  end

  # Do not cache this page.
  def set_no_cache
    response.set_header('Cache-Control', 'no-cache, no-store, max-age=0, must-revalidate')
    response.set_header('Pragma', 'no-cache')
    response.set_header('Expires', 'Fri, 01 Jan 1990 00:00:00 GMT')
  end

  private

  def set_sentry_context
    Sentry.with_scope do |scope|
      scope.set_user(id: session[:current_user_id])
      scope.set_extras(params: params.to_unsafe_h, url: request.url)
    end
  end

  def record_user_session
    return if current_user.nil?

    ip_address = request.remote_ip
    user_sessions = UserSession.where(user_id: current_user.id).order('created_at DESC').limit(1)
    last_session = user_sessions.first

    if last_session && last_session.ip_address == ip_address
      last_session.updated_at = DateTime.current
      last_session.save
    else
      UserSession.create(user_id: current_user.id, ip_address: ip_address)
    end
  end

  def verify_domain
    return if request.host == ENV['DAD_DOMAIN']

    redirect_to "https://#{ENV['DAD_DOMAIN']}#{request.original_fullpath}",
                status: :moved_permanently
  end

  include SessionsHelper
end
