# frozen_string_literal: true

class RemoveApiCommandFromSubmissions < ActiveRecord::Migration[5.0]
  def change
    remove_column :submissions, :api_command
  end
end
