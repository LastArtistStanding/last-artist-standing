# frozen_string_literal: true

# Adds avatar to users
class AddColumnsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :avatar, :string
  end
end
