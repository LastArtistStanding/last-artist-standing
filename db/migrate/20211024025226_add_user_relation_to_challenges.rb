# frozen_string_literal: true

# Adds a foreign key linking creator_id to users
class AddUserRelationToChallenges < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :challenges, :users, column: :creator_id, primary_key: 'id'
  end
end
