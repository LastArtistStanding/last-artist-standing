class CreateSiteStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :site_statuses do |t|
      t.date :current_rollover

      t.timestamps
    end
  end
end
