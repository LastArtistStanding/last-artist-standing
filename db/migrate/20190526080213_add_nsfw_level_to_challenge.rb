# frozen_string_literal: true

class AddNsfwLevelToChallenge < ActiveRecord::Migration[5.0]
  def change
    add_column :challenges, :nsfw_level, :integer, default: 1
  end
end
