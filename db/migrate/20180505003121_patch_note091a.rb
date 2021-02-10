# frozen_string_literal: true

require File.expand_path('lib/migration_helper')
include MigrationHelper

# updates patch notes
class PatchNote091a < ActiveRecord::Migration[5.0]
  def change
    updatePatchInfo
  end
end
