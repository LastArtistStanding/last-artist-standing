# frozen_string_literal: true

# Adds a foreign key linking creator_id to users
class AddUserRelationToChallenges < ActiveRecord::Migration[6.0]
  def up
    add_column :challenges, :is_site_challenge, :boolean, null: false, default: false

    # Before, creator_id = -1 indicates a deleted account, and nil indicates a site_challenge
    Challenge.all.each do |challenge|
      if challenge.creator_id.nil?
        challenge.update!(is_site_challenge: true)
      elsif challenge.creator_id == -1
        challenge.update!(creator_id: nil)
      end
    end

    add_foreign_key :challenges, :users, column: :creator_id, primary_key: 'id'
  end

  def down
    remove_foreign_key :challenges, column: :creator_id

    Challenge.all.each do |challenge|
      # if no creator_id, and not a site_challenge, clearly a deleted account
      if challenge.creator_id.nil? && !challenge.is_site_challenge
        challenge.update!(creator_id: -1)
      end
    end

    remove_column :challenges, :is_site_challenge
  end
end
