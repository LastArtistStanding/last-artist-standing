# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
end
