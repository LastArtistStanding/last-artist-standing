class CreateHouseParticipations < ActiveRecord::Migration[6.0]
  def change
    create_table :house_participations do |t|
      t.integer :user_id, null: false
      t.integer :house_id, null: false
      t.date :join_date, null: false
      t.integer :time_spent, default: 0, null: false
    end
  end
end
