# frozen_string_literal: true

class Board < ApplicationRecord
  has_many :discussions, dependent: :destroy

  def to_param
    self.alias
  end
end
