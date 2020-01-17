class NotificationsController < ApplicationController
  skip_before_action :record_user_session
  
  def index
    respond_to do |format|
      format.html do |variant|
        @unread_notifications = Notification.where(user: current_user).unread
        @unread_notifications.update_all(read_at: Time.now.utc)
        @notifications = Notification.where(user: current_user).order("created_at DESC")
      end
      format.json do |variant|
        @notifications = Notification.where(user: current_user).unread
      end
    end
    
  end
  
  def mark_as_read
    @notifications = Notification.where(user: current_user).unread
    @notifications.update_all(read_at: Time.now.utc)
    render json: { success: true }
  end
end