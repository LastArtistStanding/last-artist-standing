# frozen_string_literal: true

# Adds Index to user name
class AddIndexToUsersName < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :name, unique: true
  end
end
