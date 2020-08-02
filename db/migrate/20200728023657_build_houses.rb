# Add houses to the database
class BuildHouses < ActiveRecord::Migration[6.0]
  def change
    create_table :houses do |t|
      t.text :house_name, null: false
      t.datetime :house_start, null: false
      t.datetime :house_end, null: false
      t.integer :user_ids, array: true, default: []
    end
  end
end
