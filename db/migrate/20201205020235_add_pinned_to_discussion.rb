class AddPinnedToDiscussion < ActiveRecord::Migration[6.0]
  def change
    add_column :discussions, :pinned, :boolean, null: false, default: false
  end
end
