# frozen_string_literal: true

# Adds the marked_for_deletion and
class AddMarkedForDeletionToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.boolean :marked_for_deletion, default: false, null: false
      t.date :deletion_date, default: nil
    end
  end
end
