# frozen_string_literal: true

# adds title, description and time to submissions
class AddColumnsToSubmission < ActiveRecord::Migration[5.0]
  def change
    change_table :submissions, { bulk: true } do |t|
      t.string :title, :description
      t.integer :time
    end
  end
end
