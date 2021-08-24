# frozen_string_literal: true

class RenumberPermissionLevels < ActiveRecord::Migration[6.0]
  def up
    Board.all.each do |board|
      case board.permission_level
      when 0 # everyone
        new_level = ~0
      when 1 # everyone
        new_level = ~0
      when 2 # mods and admins
        new_level = 0b11
      when 3 # admins only
        new_level = 0b1
      else # no-one
        new_level = 0
      end
      board.update_attributes!(:permission_level => new_level)
    end
  end

  def down
    Board.all.each do |board|
      everyone_clearance = permission_level == ~0
      admin_clearance    = permission_level.anybits?(1 << 0)
      mod_clearance      = permission_level.anybits?(1 << 1)
      if everyone_clearance
        old_level = 1
      elsif mod_clearance
        old_level = 2
      elsif admin_clearance
        old_level = 3
      else
        # previous versions did not have "no clearance";
        # just use admin clearance instead.
        old_level = 3
      end
      board.update_attributes!(:permission_level => old_level)
    end
  end
end
