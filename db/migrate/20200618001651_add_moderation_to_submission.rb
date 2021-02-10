# frozen_string_literal: true

class AddModerationToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :soft_deleted, :boolean, null: false, default: false
    add_column :submissions, :approved, :boolean, null: false, default: true
    add_column :submissions, :soft_deleted_by, :integer
  end
end
