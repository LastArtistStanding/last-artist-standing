class Award < ApplicationRecord
    
    belongs_to :user
    belongs_to :badge
    
    validates :prestige, presence: true
    validates :date_received, presence: true
    
end
