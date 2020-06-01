# frozen_string_literal: true

class AddNameToUserSessions < ActiveRecord::Migration[5.0]
  def change
    add_column :user_sessions, :name, :string
  end
end
