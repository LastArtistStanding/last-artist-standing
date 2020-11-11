# frozen_string_literal: true

# represents a users participation in a house
class HouseParticipation < ApplicationRecord
  belongs_to :user
  validates :user_id, :house_id, :join_date, :score, presence: true

  # @funciton add_points
  # @abstract adds points to a users score (when submitting)
  def add_points(points)
    self.score += points
    save
  end

  # @function remove_points
  # @abstract deducts points (when deleting)
  # @note not to be used when a user is banned
  def remove_points(points)
    self.score -= points
    save
  end

  # @function update_points
  # @abstract removes points and then adds a different
  # amount of points (when updating submission time)
  # does not update if the submission is older than a month.
  def update_points(old_points, new_points, submission_created_at)
    return unless submission_created_at.to_date >= Time.now.utc.at_beginning_of_month.to_date

    self.score -= old_points
    self.score += new_points
    save
  end
end
