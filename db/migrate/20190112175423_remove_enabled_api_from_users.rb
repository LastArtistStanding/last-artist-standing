# frozen_string_literal: true

class RemoveEnabledApiFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :enabled_api
  end
end
