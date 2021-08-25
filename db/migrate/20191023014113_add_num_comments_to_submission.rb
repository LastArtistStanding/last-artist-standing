# frozen_string_literal: true

# Adds number of comments to submissions
class AddNumCommentsToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :num_comments, :integer, null: false, default: 0
  end
end
