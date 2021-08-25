# frozen_string_literal: true

class RemoveUserIdFromHouseParticipations < ActiveRecord::Migration[6.0]
  def change
    remove_column :house_participations, :user_id, :integer
  end
end
