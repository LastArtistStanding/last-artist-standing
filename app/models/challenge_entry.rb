class ChallengeEntry < ApplicationRecord

    belongs_to :challenge
    belongs_to :submission

    validates :challenge_id, presence: true
    validates :submission_id, presence: true

    validates_uniqueness_of :challenge_id, scope: :submission_id

end
