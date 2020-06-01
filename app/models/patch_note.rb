# frozen_string_literal: true

class PatchNote < ApplicationRecord
  validates :patch, presence: true, uniqueness: { case_sensitive: false }
end
