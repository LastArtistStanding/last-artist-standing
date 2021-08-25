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
        last_reply: t.comments.order('created_at DESC').first
      }

      if t.pinned
        @pinned_hashes.push(thread_hash)
      else
        @thread_hashes.push(thread_hash)
      end
    end

    @pinned_hashes = @pinned_hashes
                     .sort_by do |t|
      if t[:last_reply].present?
        t[:last_reply].created_at
      else
        DateTime.new(
          2001, 2, 3, 4, 5, 6
        )
      end
    end
                     .reverse!
    @thread_hashes = @thread_hashes
                     .sort_by do |t|
      if t[:last_reply].present?
        t[:last_reply].created_at
      else
        DateTime.new(
          2001, 2, 3, 4, 5, 6
        )
      end
    end
                     .reverse!
  end
end
