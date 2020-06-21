class RemoveUrlFromModeratorLogs < ActiveRecord::Migration[6.0]
  def change
    remove_column :moderator_logs, :url
  end
end
