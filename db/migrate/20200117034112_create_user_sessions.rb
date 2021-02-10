# frozen_string_literal: true

# Creates users sessions table
class CreateUserSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_sessions do |t|
      t.references :user, foreign_key: true
      t.string :ip_address

      t.timestamps
    end
  end
end
