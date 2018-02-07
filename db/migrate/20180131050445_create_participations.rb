class CreateParticipations < ActiveRecord::Migration[5.0]
  def change
    create_table :participations do |t|
      t.integer :user_id
      t.integer :challenge_id
      t.boolean :active
      t.integer :score
      t.boolean :eliminated
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
