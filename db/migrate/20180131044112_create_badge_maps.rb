# frozen_string_literal: true

class CreateBadgeMaps < ActiveRecord::Migration[5.0]
  def change
    create_table :badge_maps do |t|
      t.integer :badge_id
      t.integer :challenge_id
      t.integer :required_score
      t.integer :prestige
      t.string :description

      t.timestamps
    end
  end
end
