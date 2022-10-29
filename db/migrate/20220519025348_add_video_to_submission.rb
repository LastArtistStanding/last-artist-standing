# frozen_string_literal: true

#Adds the video column to submissions
class AddVideoToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :video, :string
  end
end
