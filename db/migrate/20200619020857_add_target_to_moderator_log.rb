# frozen_string_literal: true

class AddTargetToModeratorLog < ActiveRecord::Migration[6.0]
  def change
    add_reference :moderator_logs, :target, polymorphic: true
  end
end
