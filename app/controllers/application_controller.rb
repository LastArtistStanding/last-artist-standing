class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :verify_domain, if: -> { Rails.env.production? && ENV['BLOCK_HEROKU'] == 'TRUE' }
  before_action :set_raven_context
  before_action :record_user_session
  
  private
  
  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
  
  def record_user_session
    active_user = current_user
    ip_address = request.remote_ip
    if !active_user.nil?
      user_sessions = UserSession.where(user_id: active_user.id).order("created_at DESC").limit(1)
      last_session = user_sessions.first
      if last_session && last_session.ip_address == ip_address
        last_session.updated_at = DateTime.current
        last_session.save
      else
        UserSession.create(user_id: active_user.id, ip_address: ip_address)
      end
    end
  end

  def verify_domain
    unless request.host == ENV['DAD_DOMAIN']
      redirect_to "https://#{ENV['DAD_DOMAIN']}"\
        "#{request.original_fullpath}",
        status: :moved_permanently
    end
  end
  
  include SessionsHelper
end
