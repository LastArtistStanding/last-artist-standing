# frozen_string_literal: true

# Adds frequency column to user
class AddNewFrequencyToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :new_frequency, :integer
  end
end
