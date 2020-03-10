# frozen_string_literal: true

# Represents an individual piece of art submitted to the website.
class Submission < ApplicationRecord
  mount_uploader :drawing, ImageUploader

  belongs_to :user
  has_many :challenge_entries
  has_many :challenges, through: :challenge_entries
  has_many :comments, as: :source

  validates :user_id, presence: true
  validates :drawing, presence: true
  validates :title, length: { maximum: 100 }
  validates :description, length: { maximum: 2000 }
  validates :nsfw_level, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 3
  }

  def can_be_commented_on_by(user)
    commentable && (user_id == user.id || user.can_make_comments)
  end
end
