# frozen_string_literal: true

class CommentsController < ApplicationController
  include CommentsHelper
  include SubmissionsHelper

  before_action :set_target, only: %i[new create mod_action]
  before_action :set_comment, only: %i[destroy mod_action]
  before_action :ensure_authenticated, only: %i[new create destroy mod_action]
  before_action -> { ensure_authorized @comment.user_id }, only: %i[destroy]
  before_action :ensure_authorized_to_comment, only: %i[create]
  before_action :ensure_unbanned, only: %i[create destroy]
  before_action :ensure_moderator, only: %i[mod_action]

  def new
    @comment = Comment.new
  end

  def create
    @comment = @target.comments.new(comment_params)
    @comment.user_id = current_user.id
    @comment.body = @comment.body.gsub(/ +/, ' ').strip

    unless @comment.save
      flash[:error] = 'Comment failed to post: ' + @comment.errors.full_messages.join(', ')
      redirect_back(fallback_location: '/')
      return
    end

    if @target.is_a? Submission
      submission = Submission.find(@comment.source_id)
      submission.num_comments += 1
      submission.save!
    end

    send_notifications

    flash[:success] = 'Comment posted successfully!'
    redirect_back(fallback_location: '/')
  end

  def destroy
    target = @comment.source
    @comment.destroy!
    unless target.nil?
      target.num_comments -= 1
      target.save!
    end
    redirect_back(fallback_location: root_path)
  end

  # POST
  def mod_action
    if params.has_key?(:reason) && params[:reason].present?
      if params.has_key? :toggle_soft_delete
        @comment.soft_deleted = !@comment.soft_deleted
        @comment.soft_deleted_by = current_user.id if @comment.soft_deleted
        ModeratorLog.create(user_id: current_user.id,
                            target: @comment,
                            action: "#{current_user.username} has #{@comment.soft_deleted ? 'soft deleted' : 'reverted soft deletion on'} a comment made by #{@comment.user.username}.",
                            reason: params[:reason])
      end
      @comment.save
    end

    redirect_to @target
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :user_id)
  end

  def set_target
    @target = Submission.find_by(id: params[:submission_id]) if params[:submission_id]

    render_not_found if @target.nil?
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])

    render_not_found if @comment.nil?
  end

  def ensure_authorized_to_comment
    has_permission, error = @target.can_be_commented_on_by(current_user)
    return if has_permission

    flash[:error] = error
    redirect_back(fallback_location: '/')
  end

  def send_notification(message, user_id)
    Notification.create(
      body: format(message, poster: current_user.username,
                            target: "#{@target.display_title} (ID: #{@target.id})"),
      source_type: 'Comment',
      source_id: @comment.id,
      user_id: user_id,
      url: comment_html_path(@comment)
    )
  end

  def send_notifications
    # Notifications are not currently implemented for targets other than submissions.
    return unless @target.is_a? Submission

    # Send a notification to the artist unless they're the commenter.
    unless @target.user_id == current_user.id
      send_notification('%<poster>s has commented on your submission %<target>s.', @target.user_id)
    end

    discussion_users = @target.comments.select(:user_id).distinct.pluck(:user_id)
    discussion_users.each do |user_id|
      # Don't send notifications to ourselves.
      next if user_id == current_user.id
      # Don't send the artist two notifications for the same comment.
      next if @target.user_id == user_id

      send_notification('%<poster>s has also commented on submission %<target>s.', user_id)
    end
  end
end
