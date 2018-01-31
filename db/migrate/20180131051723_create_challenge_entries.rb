class CreateChallengeEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :challenge_entries do |t|
      t.integer :challenge_id
      t.integer :submission_id

      t.timestamps
    end
  end
end
