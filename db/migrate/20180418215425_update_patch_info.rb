# frozen_string_literal: true

require File.expand_path('lib/migration_helper')
include MigrationHelper
# Updates Patch Info
class UpdatePatchInfo < ActiveRecord::Migration[5.0]
  def change
    updatePatchInfo
  end
end
