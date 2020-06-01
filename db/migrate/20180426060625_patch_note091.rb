# frozen_string_literal: true

require File.expand_path('lib/migration_helper')
include MigrationHelper

class PatchNote091 < ActiveRecord::Migration[5.0]
  def change
    updatePatchInfo
  end
end
