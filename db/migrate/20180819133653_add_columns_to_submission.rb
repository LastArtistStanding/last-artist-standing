# frozen_string_literal: true

class AddColumnsToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :title, :string
    add_column :submissions, :description, :string
    add_column :submissions, :time, :integer
  end
end
