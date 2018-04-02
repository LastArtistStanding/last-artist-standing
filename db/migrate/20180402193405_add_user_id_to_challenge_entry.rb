class AddUserIdToChallengeEntry < ActiveRecord::Migration[5.0]
  def change
    add_column :challenge_entries, :user_id, :integer
    
    challenge_entries = ChallengeEntry.all
    challenge_entries.each do |ce|
      ce.user_id = ce.submission.user_id
      ce.save
    end
  end
end
