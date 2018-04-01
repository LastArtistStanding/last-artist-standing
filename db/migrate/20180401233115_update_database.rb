require File.expand_path('lib/migration_helper')
include MigrationHelper

class UpdateDatabase < ActiveRecord::Migration[5.0]
  def change
    updateDatabase
  end
end
