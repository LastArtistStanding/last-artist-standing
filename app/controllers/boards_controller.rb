# frozen_string_literal: true

# Controller for forums
class BoardsController < ApplicationController
  # @function index
  # @abstract retrieves a list of boards
  def index
    @boards = Board.all
  end

  def show
    @board = Board.find_by(alias: params[:alias])
    thread_query = Discussion.where(board_id: @board.id).includes(:comments)

    @pinned_hashes = []
    @thread_hashes = []
    thread_query.each do |t|
      thread_hash = {
        thread: t,
        num_comments: t.comments.count,
        last_reply: t.comments.order("created_at DESC").first
      }

      if t.pinned
        @pinned_hashes.push(thread_hash)
      else
        @thread_hashes.push(thread_hash)
      end
    end

    @pinned_hashes = @pinned_hashes.sort_by { |t| t[:last_reply].created_at }.reverse!
    @thread_hashes = @thread_hashes.sort_by { |t| t[:last_reply].created_at }.reverse!
  end
end
  