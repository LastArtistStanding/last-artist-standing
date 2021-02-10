# frozen_string_literal: true

class AddUserToHouseParticipations < ActiveRecord::Migration[6.0]
  def change
    add_reference :house_participations, :user, foreign_key: true
  end
end
