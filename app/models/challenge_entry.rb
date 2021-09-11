# frozen_string_literal: true

class ChallengeEntry < ApplicationRecord
  belongs_to :challenge
  belongs_to :submission
  belongs_to :user

  validates :challenge_id, presence: true
  validates :submission_id, presence: true

  validates :challenge_id, uniqueness: { scope: :submission_id }
end
