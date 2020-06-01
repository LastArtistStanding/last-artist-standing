# frozen_string_literal: true

class AddEnabledApiToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :enabled_api, :boolean
  end
end
