# frozen_string_literal: true

# Adds title column to patch_notes
class AddTitleToPatchNote < ActiveRecord::Migration[5.0]
  def change
    add_column :patch_notes, :title, :string
  end
end
