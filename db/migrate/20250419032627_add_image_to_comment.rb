class AddImageToComment < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :image, :string, null: true
  end
end
