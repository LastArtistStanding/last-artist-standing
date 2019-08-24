class AddCurrentStreakToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :current_streak, :integer, default: 0
    
    active_dads = Participation.where({challenge_id: 1, active: true})
    active_dads.each do |p|
      p.user.update_attribute(:current_streak, p.score)
    end
  end
end
