# frozen_string_literal: true

class CreateAwards < ActiveRecord::Migration[5.0]
  def change
    create_table :awards do |t|
      t.integer :badge_id
      t.integer :user_id
      t.integer :prestige
      t.date :date_received

      t.timestamps
    end
  end
end
