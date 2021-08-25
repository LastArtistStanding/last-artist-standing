# frozen_string_literal: true

class AddModerationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_moderator, :boolean, null: false, default: false
    add_column :users, :approved, :boolean, null: false, default: false

    reversible do |dir|
      dir.up do
        User.all.each do |u|
          u.update_attribute(:approved, true)
        end
      end
      dir.down do
        # The row will be deleted, so no value needs to be set.
      end
    end
  end
end
