# frozen_string_literal: true

# Adds display name to user
class AddDisplayNameToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :display_name, :string
  end
end
