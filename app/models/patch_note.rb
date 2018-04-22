class PatchNote < ApplicationRecord
    
    validates :patch, presence: true, uniqueness: { case_sensitive: false }
    
end
