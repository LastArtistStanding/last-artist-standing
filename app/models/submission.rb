# frozen_string_literal: true

# Represents an individual piece of art submitted to the website.
class Submission < ApplicationRecord
  include PagesHelper

  mount_uploader :drawing, ImageUploader

  belongs_to :user
  has_many :challenge_entries, dependent: :destroy
  has_many :challenges, through: :challenge_entries
  has_many :comments, as: :source
  # This *would* include a `dependent: :destroy` clause as well, but that causes an error:
  #   Cannot modify association 'Submission#notifications'
  #   because the source reflection class 'Notification' is associated to 'Comment' via :has_many.
  # If there is any way to solve this, feel free to do so.
  has_many :notifications, through: :comments
  has_many :moderator_logs, as: :target

  validates :user_id, presence: true
  validates :drawing, presence: true
  validates :title, length: { maximum: 100 }
  validates :description, length: { maximum: 2000 }
  validates :time, numericality: { only_integer: true, greater_than: 0, allow_nil: true }
  validates :nsfw_level, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 3
  }

  def can_be_commented_on_by(user)
    return [false, 'You must be logged in to comment.'] if user.blank?
    return [false, 'The artist has locked comments for this submission.'] unless commentable 

    ban = user.get_latest_ban
    return [false, "You have an active ban until #{date_string_short(ban.expiration)}."] unless ban.nil?
    return [true, nil] if user_id == user.id && user.verified?

    user.can_make_comments
  end

  def time_text
    return 'unspecified' if time.blank?

    "#{time} minutes"
  end

  def display_title
    return 'Untitled' if title.blank?

    title
  end

  def display_description
    return 'No description provided.' if description.blank?

    description
  end
end
