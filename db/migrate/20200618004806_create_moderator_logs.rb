class CreateModeratorLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :moderator_logs do |t|
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.string :reason
      t.string :url

      t.timestamps
    end
  end
end
