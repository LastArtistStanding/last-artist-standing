class CreateDiscussions < ActiveRecord::Migration[6.0]
  def change
    create_table :discussions do |t|
      t.string :title, null: false
      t.integer :nsfw_level, null: false
      t.references :user, foreign_key: true
      t.boolean :locked, null: false

      t.timestamps
    end
  end
end
