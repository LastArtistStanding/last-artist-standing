class AddAnonymousToComment < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :anonymous, :boolean, default: false
  end
end
