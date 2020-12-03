# frozen_string_literal: true

# Controller for forums
class DiscussionsController < ApplicationController
  before_action :get_board
  before_action :set_discussion, only: %i[destroy show]

  before_action :ensure_authenticated, only: %i[new create destroy]
  before_action -> { ensure_clearance @board.permission_level }, only: %i[new create]
  before_action :ensure_moderator, only: %i[mod_action]
  before_action -> { ensure_authorized @discussion.user_id }, only: %i[destroy]
  before_action :ensure_unbanned, only: %i[new create destroy]

  # @function index
  # @abstract retrieves a list of boards
  def index
    thread_query = Discussion.where(board_id: @board.id).includes(:comments)

    @thread_hashes = []
    thread_query.each do |t|
      @thread_hashes.push({
        thread: t,
        num_comments: t.comments.count,
        latest_post: t.comments.maximum(:created_at)
      })
    end

    @thread_hashes = @thread_hashes.sort_by { |t| t[:latest_post] }.reverse!
  end

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
    @comments = @discussion.comments.order("created_at ASC")
  end

  def destroy
    @discussion.destroy

    respond_to do |format|
      format.html { redirect_to discussions_url(@alias) }
      format.json { head :no_content }
    end
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
    