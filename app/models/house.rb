# frozen_string_literal: true

# represents a dad house
class House < ApplicationRecord
  include HousesHelper
  validates :house_name, :house_start, presence: true, allow_blank: false
  validate :house_name_unique
  validate :house_not_old
  has_many :house_participations, dependent: :nullify

  # @function add_user
  # @abstract adds the current user
  def add_user(uid)
    return false unless can_join?(uid)

    score = User.find(uid).submissions
                .where('created_at >= ?', search_date).sum('submissions.time').to_i / 30
    HouseParticipation
      .create(user_id: uid, house_id: id, join_date: Time.now.utc.to_date, score: score)
  end

  # @function participants
  # @return Active Record each users user name and score
  # @note will return nil for the name if the user was banned or deleted
  def users
    HouseParticipation
      .joins('LEFT OUTER JOIN users ON users.id = house_participations.user_id')
      .where(house_participations: { house_id: id })
      .select('users.name as name, house_participations.score as score')
      .order('score DESC')
  end

  # @function total_score
  # @return the total score for this house
  def total
    users.sum('house_participations.score')
  end

  # @function place
  # @return the ranked place compared ot rival houses based on score ("first", "second", or "third")
  # @note teams can tie for first and second.
  def place
    return 'first' if first?

    return 'second' if second?

    'third'
  end

  # @function is_unbalanced?
  # @return true if this house has 6 or more users than any any other house
  def unbalanced?
    users.length - rival(0).users.length > 5 || users.length - rival(1).users.length > 5
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
    !in_a_house?(uid) && !unbalanced? && !old_house?
  end

  def search_date
    (Time.now.utc.to_date - house_start).to_i > 10 ? Time.now.utc.to_date - 10 : house_start
  end

  def rival(index)
    House.where('house_start = ? AND id != ?', house_start, id)[index]
  end

  def first?
    total >= rival(0).total && total >= rival(1).total
  end

  def second?
    (total < rival(0).total) && (total >= rival(1).total) ||
      (total < rival(1).total) && (total >= rival(0).total)
  end
end
