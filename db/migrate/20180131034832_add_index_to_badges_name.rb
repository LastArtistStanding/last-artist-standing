# frozen_string_literal: true

class AddIndexToBadgesName < ActiveRecord::Migration[5.0]
  def change
    add_index :badges, :name, unique: true
  end
end
