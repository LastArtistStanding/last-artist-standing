class AddMarkedForDeathToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :marked_for_death, :boolean, null: false, default: false
  end
end
