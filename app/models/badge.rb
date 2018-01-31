class Badge < ApplicationRecord
    
    has_many :awards
    has_many :badge_maps
    has_many :users, through: :awards
    has_many :challenges, through: :badge_maps
    
    validates :name, presence: true, length: { maximum: 255 }, uniqueness: {case_sensitive: false }
    
end
