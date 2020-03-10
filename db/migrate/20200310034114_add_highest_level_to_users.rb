class AddHighestLevelToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :highest_level, :integer, default: 0

    all_users = User.all
    all_users.each do |u|
      if u.longest_streak > 0
        highest_level = BadgeMap.where("required_score <= #{u.longest_streak} AND challenge_id = 1").order("required_score DESC").first.prestige
        u.update_attribute(:highest_level, highest_level)
      end
    end
  end
end
