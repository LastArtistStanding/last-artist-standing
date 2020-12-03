class CreateBoards < ActiveRecord::Migration[6.0]
  def change
    create_table :boards do |t|
      t.string :title
      t.integer :permission_level
      t.string :alias

      t.timestamps
    end
    add_index :boards, :alias
  end
end
