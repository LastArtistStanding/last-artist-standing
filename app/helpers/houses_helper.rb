module HousesHelper

  def is_in_a_house?
    return false unless current_user
    HouseParticipation.where('user_id = ? AND join_date >= ?', current_user.id, Time.now.utc.at_beginning_of_month.to_date).any?
  end
end
