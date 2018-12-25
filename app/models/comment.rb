class Comment < ApplicationRecord
  belongs_to :source, polymorphic: true
  
  validates :user_id, presence: true
  validates :body, length: { minimum: 140, maximum: 2000 }
end
