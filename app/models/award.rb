class Award < ApplicationRecord

    belongs_to :user
    belongs_to :badge

    validates :user_id, presence: true
    validates :badge_id, presence: true
    validates :prestige, presence: true, numericality: { only_integer: true }
    validates :date_received, presence: true

    validates_uniqueness_of :user_id, scope: :badge_id

end
