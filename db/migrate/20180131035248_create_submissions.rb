# frozen_string_literal: true

class CreateSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :submissions do |t|
      t.integer :user_id
      t.string :drawing
      t.integer :nsfw_level

      t.timestamps
    end
  end
end
