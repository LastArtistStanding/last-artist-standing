# frozen_string_literal: true

# Adds commentable column to submissions
class AddCommentableToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :commentable, :boolean
  end
end
