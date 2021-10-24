# frozen_string_literal: true

# Represents a challenge on the website.
class Challenge < ApplicationRecord
  include MarkdownHelper

  belongs_to :creator, class_name: 'User'
  has_many :badge_maps, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :notifications, as: :source, dependent: :destroy
  has_many :challenge_entries, dependent: :destroy
  has_many :users, through: :participations
  has_many :badges, through: :badge_maps, dependent: :destroy
  has_many :moderator_logs, as: :target

  NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z/.freeze

  validates :name, presence: true, length: { maximum: 100 },
                   format: { with: NO_EXCESS_WHITESPACE }, uniqueness: { case_sensitive: false }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :start_date, presence: true
  validates :nsfw_level, presence: true, numericality: { only_integer: true,
                                                         greater_than_or_equal_to: 1,
                                                         less_than_or_equal_to: 3 }
  # There is no required end date, indicating an indefinte challenge
  # (should only apply to the primary DED challenge).
  # NOTE: End date should be EXCLUSIVE, not INCLUSIVE
  validates :postfrequency, presence: true, numericality: { only_integer: true,
                                                            greater_than_or_equal_to: -1,
                                                            less_than_or_equal_to: 7 }

  validate :end_date_cannot_precede_start_date

  def link_form
    render_markdown(description)
  end

  def can_delete?
    Time.now.utc.to_date < start_date
  end

  def end_date_cannot_precede_start_date
    return unless end_date.present? && end_date <= start_date

    errors.add(:end_date, ' cannot precede or equal start date.')
  end

  def self.current_season
    Challenge.where(':todays_date >= start_date AND :todays_date < end_date AND seasonal = true',
                    { todays_date: Time.now.utc.to_date }).first
  end
end
