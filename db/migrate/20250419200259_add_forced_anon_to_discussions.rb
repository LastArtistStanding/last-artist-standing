class AddForcedAnonToDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :discussions, :force_anon, :boolean, null: true, default: false
  end
end
