class Participation < ApplicationRecord
    
    belongs_to :user
    belongs_to :challenge
    
    validates :active, presence: true
    validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :eliminated, presence: true
    validates :start_date, presence: true
    validate :end_date_cannot_precede_start_date
    
    def end_date_cannot_precede_start_date
        if end_date.present? && end_date < start_date
            erros.add(:end_date, "End date cannot precede start date.")
        end
    end
    
end
