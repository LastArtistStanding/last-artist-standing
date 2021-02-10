# frozen_string_literal: true

# Adds seasonal column to challenges
class AddSeasonalToChallenges < ActiveRecord::Migration[5.0]
  def change
    add_column :challenges, :seasonal, :boolean, default: false
  end
end
