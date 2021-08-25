# frozen_string_literal: true

# Adds is_animated_gif to submissions
class AddIsAnimatedGifToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :is_animated_gif, :boolean, null: false, default: false
  end
end
