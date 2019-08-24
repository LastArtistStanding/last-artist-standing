class Challenge < ApplicationRecord
  has_many :badge_maps
  has_many :participations
  has_many :challenge_entries
  has_many :users, through: :participations
  has_many :badges, through: :badge_maps
  
  NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z/
  
  validates :name, presence: true, length: { maximum: 50 }, format: { with: NO_EXCESS_WHITESPACE }, uniqueness: {case_sensitive: false }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :start_date, presence: true
  validates :nsfw_level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 3 }
  #There is no required end date, indicating an indefinte challenge (should only apply to the primary DED challenge).
  #NOTE: End date should be EXCLUSIVE, not INCLUSIVE
  validates :postfrequency, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 7 }
  
  validate :end_date_cannot_precede_start_date
  
  def end_date_cannot_precede_start_date
    if end_date.present? && end_date <= start_date
      errors.add(:end_date, " cannot precede or equal start date.")
    end
  end
  
  def self.currentSeasonalChallenge
    Challenge.where(":todays_date >= start_date AND :todays_date < end_date AND seasonal = true", {todays_date: Date.current}).first
  end
end
