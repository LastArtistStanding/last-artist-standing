class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :nsfw_level, :integer
    add_column :users, :is_admin, :boolean
    add_column :users, :dad_frequency, :integer
  end
end
