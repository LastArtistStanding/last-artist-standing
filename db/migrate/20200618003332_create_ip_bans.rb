class CreateIpBans < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_bans do |t|
      t.string :ip, null: false
      t.string :alias, null: false
      t.string :reason, null: false
      t.string :notes

      t.timestamps
    end
  end
end
