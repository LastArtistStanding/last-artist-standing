class AddAnonymousToDiscussion < ActiveRecord::Migration[6.0]
  def change
    add_column :discussions, :anonymous, :boolean, default: false
  end
end
