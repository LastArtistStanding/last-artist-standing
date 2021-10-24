# frozen_string_literal: true

# Create UserFeedback Table
class CreateUserFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :user_feedbacks do |t|
      t.references :user, foreign_key: true
      t.string :title, null: false
      t.string :body, null: false

      t.timestamps
    end
  end
end
