# frozen_string_literal: true

# Creates the notifications table
class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.references :source, polymorphic: true, index: true
      t.string :body
      t.datetime :read_at

      t.timestamps
    end
  end
end
