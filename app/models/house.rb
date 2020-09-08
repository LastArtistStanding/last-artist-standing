# frozen_string_literal: true

# represents a dad house
class House < ApplicationRecord
  include HousesHelper
  validates :house_name, :house_start, presence: true, allow_blank: false
  validate :house_name_unique
  validate :house_not_old
  has_many :house_participations

  # @function add_user
  # @abstract adds the current user
  def add_user uid
    return false if is_in_a_house?(uid) || is_unbalanced? || is_old_house?
    # add the last 10 days of submissions if they are joining late in the month
    search_date = (Time.now.utc.to_date - house_start).to_i > 10 ? Time.now.utc.to_date - 10 : house_start
    score = User.find(uid).submissions.where("created_at >= ?", search_date).sum("submissions.time").to_i / 30
    HouseParticipation.create(user_id: uid, house_id: id, join_date: Time.now.utc.to_date, score: score)
    true
  end

  # @function participants
  # @return Active Record each participants user name and score
  # @note will return nil for the name if the user was banned or deleted
  def participants
    HouseParticipation.joins("LEFT OUTER JOIN users ON users.id = house_participations.user_id")
        .where(house_participations: {house_id: id})
        .select("users.name as name, house_participations.score as score")
        .order("score DESC")
  end

  # @function total_score
  # @return the total score for this house
  def total_score
    participants.sum("house_participations.score")
  end

  # @function place
  # @return the ranked place compared ot rival houses based on score ("first", "second", or "third")
  # @note teams can tie for first and second.
  def place
    rival_houses = House.where("house_start = ? AND id != ?", house_start, id)
    return "first" if (total_score >= rival_houses[0].total_score) && (total_score >= rival_houses[1].total_score)
    return "second" if (total_score < rival_houses[0].total_score) && (total_score >= rival_houses[1].total_score)
    return "second" if (total_score < rival_houses[1].total_score) && (total_score >= rival_houses[0].total_score)
    "third"
  end

  # @function is_unbalanced?
  # @return true if this house has 6 or more participants than any any other house
  def is_unbalanced?
    rival_houses = House.where("house_start = ? AND id != ?", house_start, id)
    return true if ((participants.length - rival_houses[0].participants.length) > 5) || ((participants.length - rival_houses[1].participants.length) > 5)
    false
  end

  # @function is_old_house?
  # @return true if this house is older than a month
  def is_old_house?
    house_start < Time.now.utc.at_beginning_of_month.to_date
  end

  private

  def house_name_unique
    House.where("house_start = ? AND id != ?", house_start, id).each do |h|
      if h.house_name == house_name
        errors.add(:house_name, "-- Rival houses must have unique names.")
        return false
      end
    end
    true
  end

  def house_not_old
    if is_old_house?
      errors.add(:house_name, "-- Cannot update an old house.")
      false
    end
  end
end
