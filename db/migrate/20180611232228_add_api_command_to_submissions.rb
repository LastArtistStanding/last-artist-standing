# frozen_string_literal: true

# adds api command column to submissions
class AddApiCommandToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :api_command, :string
  end
end
