# frozen_string_literal: true

# Adds longest streak column to users
class AddLongestStreakToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :longest_streak, :integer, default: 0
  end
end
