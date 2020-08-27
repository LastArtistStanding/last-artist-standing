# frozen_string_literal: true

# represents a dad house
class House < ApplicationRecord
  validates :house_name, :house_start, presence: true
  has_many :house_participations

  def initialize(*args)
    super(*args)
  end

  # returns all users participating in this house
  def participants
    User.joins(:house_participations)
        .where(house_participations: {house_id: id})
        .select("users.name as name, house_participations.time_spent as score")
        .order('score DESC')
  end

  def total_score
    participants.sum("house_participations.time_spent")
  end

  def place
    rival_houses = House.where("house_start = ? AND id != ?", house_start, id)
    return "first" if (total_score >= rival_houses[0].total_score) && (total_score >= rival_houses[1].total_score)
    return "second" if (total_score < rival_houses[0].total_score) && (total_score >= rival_houses[1].total_score)
    return "second" if (total_score < rival_houses[1].total_score) && (total_score >= rival_houses[0].total_score)
    "third"
  end

  private
end
