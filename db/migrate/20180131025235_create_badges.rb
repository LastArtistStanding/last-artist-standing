class CreateBadges < ActiveRecord::Migration[5.0]
  def change
    create_table :badges do |t|
      t.string :name
      t.string :avatar
      t.string :direct_image

      t.timestamps
    end
  end
end
