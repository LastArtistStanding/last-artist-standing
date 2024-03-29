# frozen_string_literal: true

# Migration Adds index to user Email
class AddIndexToUsersEmail < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :email, unique: true
  end
end
