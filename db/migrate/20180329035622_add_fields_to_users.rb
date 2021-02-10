# frozen_string_literal: true

# Adds nsfw_level, is_admin, and dad_frequency to users
class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users, { bulk: true } do |t|
      t.integer :nsfw_level, :dad_frequency
      t.boolean :is_admin
    end
  end
end
