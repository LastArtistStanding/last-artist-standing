# frozen_string_literal: true

class CreateChallenges < ActiveRecord::Migration[5.0]
  def change
    create_table :challenges do |t|
      t.string :name
      t.string :description
      t.date :start_date
      t.date :end_date
      t.boolean :streak_based
      t.boolean :rejoinable
      t.integer :postfrequency

      t.timestamps
    end
    add_index :challenges, :name
  end
end
