class CreateUserBlocks < ActiveRecord::Migration[6.0]
  def change
    create_table :user_blocks do |t|
      t.string :ip, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
