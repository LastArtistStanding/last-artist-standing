# frozen_string_literal: true

class ModeratorLog < ApplicationRecord
  belongs_to :user
  belongs_to :target, polymorphic: true
end
