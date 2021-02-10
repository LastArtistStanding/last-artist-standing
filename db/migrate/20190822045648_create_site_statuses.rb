# frozen_string_literal: true

# Creates the site_statuses table
class CreateSiteStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :site_statuses do |t|
      t.date :current_rollover

      t.timestamps
    end
  end
end
