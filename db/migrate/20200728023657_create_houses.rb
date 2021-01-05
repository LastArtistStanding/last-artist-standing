# frozen_string_literal: true

# Add houses to the database
class CreateHouses < ActiveRecord::Migration[6.0]
  def change
    create_table :houses do |t|
      t.text :house_name, null: false
      t.date :house_start, null: false
      t.timestamps
    end
  end
end
