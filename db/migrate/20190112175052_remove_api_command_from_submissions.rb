# frozen_string_literal: true

# Removes api command from submissions
class RemoveApiCommandFromSubmissions < ActiveRecord::Migration[5.0]
  def change
    remove_column(:submissions, :api_command, :string)
  end
end
