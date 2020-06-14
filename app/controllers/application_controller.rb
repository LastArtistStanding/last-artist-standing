# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :verify_domain, if: -> { Rails.env.production? && ENV['BLOCK_HEROKU'] == 'TRUE' }
  before_action :set_raven_context
  before_action :record_user_session

  protected

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
    # FIXME: This should render JSON or HTML as appropriate.
    render file: "#{Rails.root}/public/404.html", status: :not_found
  end

  def render_not_found_json
    render json: { status: 404, error: 'Not Found' }, status: :not_found
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

  # Do not cache this page.
  def set_no_cache
    response.set_header('Cache-Control', 'no-cache, no-store, max-age=0, must-revalidate')
    response.set_header('Pragma', 'no-cache')
    response.set_header('Expires', 'Fri, 01 Jan 1990 00:00:00 GMT')
  end

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
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
