class AddSubmittedToParticipations < ActiveRecord::Migration[5.0]
  def change
    add_column :participations, :submitted, :boolean
  end
end
