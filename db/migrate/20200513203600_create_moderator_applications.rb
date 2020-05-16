class CreateModeratorApplications < ActiveRecord::Migration[6.0]
  def change
    create_table :moderator_applications do |t|
      t.references :user, foreign_key: true, null: false, unique: true
      t.timestamps
      t.string :time_zone, null: false
      # Limit of 2000 chosen arbitrarily.
      t.text :active_hours, null: false, limit: 2000
      t.text :why_mod, null: false, limit: 2000
      t.text :past_experience, null: false, limit: 2000
      t.text :how_long, null: false, limit: 2000
      t.text :why_dad, null: false, limit: 2000
      t.text :anything_else, limit: 2000
    end
  end
end
