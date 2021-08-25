# frozen_string_literal: true

# Adds highest level to users
class AddHighestLevelToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :highest_level, :integer, default: 0

    all_users = User.all
    all_users.each do |u|
      next unless u.longest_streak.positive?

      highest_level = BadgeMap
                      .where("required_score <= #{u.longest_streak} AND challenge_id = 1")
                      .order('required_score DESC').first.prestige
      u.update(highest_level: highest_level)
    end
  end
end
