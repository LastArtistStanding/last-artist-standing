# frozen_string_literal: true

# Adds url to notifications
class AddUrLtoNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :url, :string
  end
end
