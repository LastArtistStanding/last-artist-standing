# frozen_string_literal: true

class AddColumnsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :avatar, :string
  end
end
