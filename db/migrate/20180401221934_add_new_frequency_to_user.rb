# frozen_string_literal: true

class AddNewFrequencyToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :new_frequency, :integer
  end
end
