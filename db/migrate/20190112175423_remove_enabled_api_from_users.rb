# frozen_string_literal: true

# Remove enabled api from users
class RemoveEnabledApiFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column(:users, :enabled_api, :boolean)
  end
end
