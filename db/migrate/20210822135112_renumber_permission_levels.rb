# frozen_string_literal: true

class RenumberPermissionLevels < ActiveRecord::Migration[6.0]
  def up
    Board.all.each do |board|
      new_level = case board.permission_level
                  when 0 # everyone
                    ~0
                  when 1 # everyone
                    ~0
                  when 2 # mods and admins
                    0b11
                  when 3 # admins only
                    0b1
                  else # no-one
                    0
                  end
      board.update!(permission_level: new_level)
    end
  end

  def down
    Board.all.each do |board|
      everyone_clearance = permission_level == ~0
      admin_clearance    = permission_level.anybits?(1 << 0)
      mod_clearance      = permission_level.anybits?(1 << 1)
      old_level = if everyone_clearance
                    1
                  elsif mod_clearance
                    2
                  elsif admin_clearance
                    3
                  else
                    # previous versions did not have "no clearance";
                    # just use admin clearance instead.
                    3
                  end
      board.update!(permission_level: old_level)
    end
  end
end
