class Board < ApplicationRecord
  has_many :discussions

  def to_param
    self.alias
  end
end
