# frozen_string_literal: true

class AddUrLtoNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :url, :string
  end
end
