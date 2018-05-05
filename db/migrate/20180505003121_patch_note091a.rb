require File.expand_path('lib/migration_helper')
include MigrationHelper

class PatchNote091a < ActiveRecord::Migration[5.0]
  def change
    updatePatchInfo
  end
end
