class AddAllowAnonToDiscussions < ActiveRecord::Migration[6.0]
  def change
    add_column :discussions, :allow_anon, :boolean, default: false
  end
end
