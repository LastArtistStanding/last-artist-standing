# frozen_string_literal: true

# Controller for forums
class DiscussionsController < ApplicationController
  before_action :get_board
  before_action :set_discussion, only: %i[destroy show mod_action]

  before_action :ensure_authenticated, only: %i[new create destroy]
  before_action -> { ensure_clearance @board.permission_level }, only: %i[new create]
  before_action :ensure_moderator, only: %i[mod_action]
  before_action -> { ensure_authorized @discussion.user_id }, only: %i[destroy]
  before_action :ensure_unbanned, only: %i[new create destroy]

  def new
    @discussion = Discussion.new
    @comment = Comment.new
  end

  def create
    @discussion = Discussion.new(discussion_params)
    @discussion.user_id = current_user.id
    @discussion.board_id = @board.id
    @discussion.locked = false

    @comment = @discussion.comments.new(comment_params)
    @comment.user_id = current_user.id
    @comment.body = @comment.body.gsub(/ +/, ' ').strip

    respond_to do |format|
      if @comment.valid? && @discussion.valid?
        @discussion.save
        @comment.save

        format.html { redirect_to discussion_path(@alias, @discussion) }
      else
        format.html { render :new }
      end
    end
  end

  def show
    @board = @discussion.board
    @comments = @discussion.comments.order("created_at ASC")
  end

  def destroy
    @discussion.destroy

    respond_to do |format|
      format.html { redirect_to discussions_url(@alias) }
      format.json { head :no_content }
    end
  end

  # POST
  def mod_action
    if params.has_key? :toggle_pinned
      @discussion.pinned = !@discussion.pinned
      ModeratorLog.create(user_id: current_user.id,
                          target: @discussion,
                          action: "#{current_user.username} has #{@discussion.pinned ? 'pinned' : 'unpinned'} #{@discussion.title}.",
                          reason: "")
    elsif params.has_key? :toggle_locked
      @discussion.locked = !@discussion.locked
      ModeratorLog.create(user_id: current_user.id,
                          target: @discussion,
                          action: "#{current_user.username} has #{@discussion.locked ? 'locked' : 'unlocked'} #{@discussion.title}.",
                          reason: "")
    end
    @discussion.save

    redirect_to @discussion
  end

  private

  def get_board
    @alias = params[:alias]
    @board = Board.find_by(alias: @alias)
  end

  def set_discussion
    @discussion = Discussion.find(params[:id])
  end

  def discussion_params
    params.require(:discussion).permit(:title, :nsfw_level)
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
    