# frozen_string_literal: true

# Adds reset_digest and reset_sent_at columns to users
class AddResetToUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users, { bulk: true } do |t|
      t.string :reset_digest
      t.datetime :reset_sent_at
    end
  end
end
