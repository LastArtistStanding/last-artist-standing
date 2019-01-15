class Comment < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :user
  
  validates :user_id, presence: true
  validates :body, length: { minimum: 100, maximum: 2000 }
end
