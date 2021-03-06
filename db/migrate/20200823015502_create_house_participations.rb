# frozen_string_literal: true

# Migration to create house participations
class CreateHouseParticipations < ActiveRecord::Migration[6.0]
  def change
    create_table :house_participations do |t|
      t.integer :user_id, null: false
      t.integer :house_id, null: false
      t.date :join_date, null: false
      t.integer :score, null: false

      t.timestamps
    end
  end
end
