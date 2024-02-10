class AddHistoryToComment < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :history, :string, array: true, default: []
  end
end
