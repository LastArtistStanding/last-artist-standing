class PatchEntry < ApplicationRecord
    
    belongs_to :PatchNote
    
    validates :patchnote_id, presence: true
    validates :body, presence: true
    validates :importance, presence: true
    
end
