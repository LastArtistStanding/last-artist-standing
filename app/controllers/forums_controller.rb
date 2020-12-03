# frozen_string_literal: true

# Controller for forums
class ForumsController < ApplicationController
  # @function index
  # @abstract retrieves a list of boards
  def index
    @boards = Board.all
  end
end
  