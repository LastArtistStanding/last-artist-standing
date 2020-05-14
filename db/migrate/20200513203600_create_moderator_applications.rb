class CreateModeratorApplications < ActiveRecord::Migration[6.0]
  def change
    create_table :moderator_applications do |t|
      t.references :user, foreign_key: true
      t.timestamps
      t.string :time_zone
      t.text :active_hours
      t.text :why_mod
      t.text :past_experience
      t.text :how_long
      t.text :why_dad
      t.text :anything_else
    end
  end
end
