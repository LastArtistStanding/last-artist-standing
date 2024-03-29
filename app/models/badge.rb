# frozen_string_literal: true

# Represents a badge on the website. Note, this is different from Award, which
# represents an instance of a badge being awarded to someone for completing a challenge.
class Badge < ApplicationRecord
  mount_uploader :avatar, ImageUploader

  has_many :awards, dependent: :destroy
  has_many :badge_maps, dependent: :destroy
  has_many :users, through: :awards
  has_many :challenges, through: :badge_maps

  NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z/.freeze

  validates :name, presence: true,
                   length: { maximum: 100 },
                   format: { with: NO_EXCESS_WHITESPACE },
                   uniqueness: { case_sensitive: false }
  validate :avatar_exists

  def avatar_exists
    return unless avatar.blank? && direct_image.blank?

    errors.add(:avatar, 'should be provided for the badge.')
  end

  def avatar_url
    direct_image || avatar.avatar.url
  end
end
