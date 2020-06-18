class CreateSiteBans < ActiveRecord::Migration[6.0]
  def change
    create_table :site_bans do |t|
      t.references :user, foreign_key: true
      t.string :ban_type, null: false
      t.date :expiration, null: false
      t.string :reason, null: false

      t.timestamps
    end
  end
end
