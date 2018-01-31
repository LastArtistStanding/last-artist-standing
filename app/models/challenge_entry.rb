class ChallengeEntry < ApplicationRecord
    
    belongs_to :challenge
    belongs_to :submission
    
end
