class CreateSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :submissions do |t|
      t.integer :user_id
      t.string :drawing
      t.string :thumbnail
      t.integer :nsfw_level

      t.timestamps
    end
    add_index :submissions, :drawing, unique: true
  end
end
