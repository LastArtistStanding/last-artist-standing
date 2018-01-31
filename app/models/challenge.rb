class Challenge < ApplicationRecord
    
    has_many :badge_maps
    has_many :participations
    has_many :challenge_entries
    has_many :users, through: :participations
    has_many :badges, through: :badge_maps
    
    NOT_ALL_WHITESPACE_REGEX = /^\s*$/
    
    validates :name, presence: true, length: { maximum: 255 }, format: { with: NOT_ALL_WHITESPACE_REGEX }, uniqueness: {case_sensitive: false }
    validates :description, presence: true, length: { maximum: 1000 }, format: { with: NOT_ALL_WHITESPACE_REGEX }
    validates :start_date, presence: true
    #There is no required end date, indicating an indefinte challenge (should only apply to the primary DED challenge).
    validates :streak_based, presence: true
    validates :rejoinable, presence: true
    
end
