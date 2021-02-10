# frozen_string_literal: true

class Discussion < ApplicationRecord
  belongs_to :user
  belongs_to :board
  has_many :comments, as: :source

  validates :title, length: { maximum: 100 }, presence: true
  validates :nsfw_level, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 3
  }

  def can_be_commented_on_by(user)
    return [false, 'You must be logged in to comment.'] if user.blank?
    return [false, 'This thread has been locked.'] if locked

    ban = user.get_latest_ban
    unless ban.nil?
      return [false, "You have an active ban until #{date_string_short(ban.expiration)}."]
    end
    return [true, nil] if user_id == user.id && user.verified?

    user.can_make_comments
  end
end
