# frozen_string_literal: true

# Creates patch_entries table
class CreatePatchEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :patch_entries do |t|
      t.integer :patchnote_id
      t.string :body
      t.integer :importance

      t.timestamps
    end
  end
end
