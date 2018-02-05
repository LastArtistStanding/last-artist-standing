class BadgeMap < ApplicationRecord
    
    belongs_to :badge
    belongs_to :challenge
    
    validates :badge_id, presence: true
    validates :challenge_id, presence: true
    validates :required_score, numericality: { only_integer: true, greater_than: 0 }
    validates :prestige, presence: true, numericality: { only_integer: true }
    validates :description, presence: true, length: { maximum: 1000 }
    
    validates_uniqueness_of :badge_id, scope: [:challenge_id, :prestige]
    
end
