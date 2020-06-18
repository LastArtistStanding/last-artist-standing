class AddModerationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :submission_ban, :date
    add_column :users, :comment_ban, :date
    add_column :users, :challenge_ban, :date
    add_column :users, :is_moderator, :boolean, null: false, default: false
    add_column :users, :approved, :boolean, null: false, default: true
  end
end
