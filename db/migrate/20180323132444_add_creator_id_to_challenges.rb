class AddCreatorIdToChallenges < ActiveRecord::Migration[5.0]
  def change
    add_column :challenges, :creator_id, :integer
  end
end
