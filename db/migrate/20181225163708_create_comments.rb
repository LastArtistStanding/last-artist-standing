# frozen_string_literal: true

# Creates comments table
class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.string :body
      t.references :source, polymorphic: true, index: true
      t.integer :user_id

      t.timestamps
    end
  end
end
