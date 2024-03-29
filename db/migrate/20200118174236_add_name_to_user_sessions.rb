# frozen_string_literal: true

# Add names to user sessions
class AddNameToUserSessions < ActiveRecord::Migration[5.0]
  def change
    add_column :user_sessions, :name, :string
  end
end
