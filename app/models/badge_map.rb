class BadgeMap < ApplicationRecord
    
    belongs_to :badge
    belongs_to :challenge
    
    NOT_ALL_WHITESPACE_REGEX = /^\s*$/
    
    validates :prestige, presence: true
    validates :description, presence: true, length: { maximum: 1000 }, format: { with: NOT_ALL_WHITESPACE_REGEX }
    
end
