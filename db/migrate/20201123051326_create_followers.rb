# frozen_string_literal: true

# Creates the Followers table
class CreateFollowers < ActiveRecord::Migration[6.0]
  def change
    create_table :followers do |t|
      t.references :user      # user is the person that is DOING the following
      t.references :following # following is the person that is BEING followed

      t.timestamps
    end
  end
end
