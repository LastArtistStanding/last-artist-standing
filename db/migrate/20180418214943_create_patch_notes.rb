class CreatePatchNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :patch_notes do |t|
      t.string :before
      t.string :after
      t.string :patch

      t.timestamps
    end
    add_index :patch_notes, :patch, unique: true
  end
end
