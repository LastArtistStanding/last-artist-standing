class Submission < ApplicationRecord
    
    belongs_to :user
    has_many :challenge_entries
    has_many :challenges, through: :challenge_entries
    
    validates :user_id, presence: true
    validates :drawing, presence: true, uniqueness: { case_sensitive: true }
    validates :thumbnail, presence: true
    validates :nsfw_level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 3 }
    
end
