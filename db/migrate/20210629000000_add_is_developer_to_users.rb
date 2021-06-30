# frozen_string_literal: true

class AddIsDeveloperToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_developer, :boolean, null: false, default: false
  end
end
