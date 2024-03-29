# frozen_string_literal: true

# represents a dad house
class House < ApplicationRecord
  include HousesHelper
  validates :house_name, :house_start, presence: true, allow_blank: false
  validate :house_name_unique
  validate :house_not_old
  has_many :house_participations, dependent: :destroy

  # @function add_user
  # @abstract adds the current user
  def add_user(uid)
    return can_join?(uid) if can_join?(uid).present?

    score = User.find(uid).submissions
                .where('created_at >= ?', search_date).sum('submissions.time').to_i
    HouseParticipation
      .create(user_id: uid, house_id: id, join_date: Time.now.utc.to_date, score: score)
  end

  # @function participants
  # @return Active Record each users user name and score
  # @note will return nil for the name if the user was banned or deleted
  def users
    HouseParticipation
      .where(house_participations: { house_id: id })
      .includes(:user)
      .order('score DESC')
  end

  # @function total_score
  # @return the total score for this house
  def total
    users.sum('house_participations.score')
  end

  # @function place
  # @return the ranked place compared ot rival houses based on score
  def place
    (1 + (House
      .where('house_start = ?', house_start)
      .sort_by { |h| -h.total })
      .find_index { |h| h.id == id }).ordinalize
  end

  # @function is_unbalanced?
  # @return true if this house has 3 or more users than any any other house
  def unbalanced?
    users.length - rival(0).users.length > 2 || users.length - rival(1).users.length > 2
  end

  # @function is_old_house?
  # @return true if this house is older than a month
  def old_house?
    house_start < Time.now.utc.at_beginning_of_month.to_date
  end

  private

  def house_name_unique
    errors.add(:house_name, '-- Rival houses must have unique names.') if
      House
      .where('house_start = ? AND id != ? AND house_name = ?', house_start, id, house_name)
      .any?
    House
      .where('house_start = ? AND id != ? AND house_name = ?', house_start, id, house_name)
      .none?
  end

  def house_not_old
    errors.add(:house_name, '-- Cannot update an old house.') if old_house?
    !old_house?
  end

  def can_join?(uid)
    if in_a_house?(uid)
      'you are already in a house'
    elsif unbalanced?
      'this house has too many members.' \
             ' Join a different house or wait for more people to join other houses'
    elsif old_house?
      'this is an old house'
    else
      ''
    end
  end

  def search_date
    (Time.now.utc.to_date - house_start).to_i > 10 ? Time.now.utc.to_date - 10 : house_start
  end

  def rival(index)
    House.where('house_start = ? AND id != ?', house_start, id)[index]
  end
end
