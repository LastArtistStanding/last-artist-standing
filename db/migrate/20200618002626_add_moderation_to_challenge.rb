class AddModerationToChallenge < ActiveRecord::Migration[6.0]
  def change
    add_column :challenges, :soft_deleted, :boolean, null: false, default: false
    add_column :challenges, :soft_deleted_by, :integer
  end
end
