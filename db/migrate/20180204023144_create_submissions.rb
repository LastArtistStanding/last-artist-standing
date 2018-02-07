class CreateSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :submissions do |t|
      t.string :drawing
      t.integer :nsfw_level

      t.timestamps
    end
  end
end
