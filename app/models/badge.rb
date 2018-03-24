class Badge < ApplicationRecord
    mount_uploader :avatar, ImageUploader
    
    has_many :awards
    has_many :badge_maps
    has_many :users, through: :awards
    has_many :challenges, through: :badge_maps
    
    NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z/
    
    validates :name, presence: true, length: { maximum: 50 }, format: { with: NO_EXCESS_WHITESPACE }, uniqueness: { case_sensitive: false }
    
    validate :badge_graphic_exists
    
    def badge_graphic_exists
      if !avatar.present? && !direct_image.present?
        errors.add(:avatar, "should be provided for the badge.")
      end
    end
end
