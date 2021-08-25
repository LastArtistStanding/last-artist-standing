# frozen_string_literal: true

# Adds nsfw level to badges
class AddNsfwLevelToBadge < ActiveRecord::Migration[5.0]
  def change
    add_column :badges, :nsfw_level, :integer, default: 1
  end
end
