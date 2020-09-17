class CreateFollowers < ActiveRecord::Migration[6.0]
  def change
    create_table :followers do |t|
      t.references :follower_user
      t.references :followed_user

      t.timestamps
    end
    add_foreign_key :followers, :users, column: :follower_user_id, primary_key: :id
    add_foreign_key :followers, :users, column: :followed_user_id, primary_key: :id
  end
end
