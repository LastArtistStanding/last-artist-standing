module HousesHelper

  # @function is_in_a_house?
  # @abstract checks to see if a user is in a house
  # @param uid - the user's id
  # @return true if they are in a house, false if they are not in a house or are not logged in
  def is_in_a_house? uid
    HouseParticipation.where('user_id = ? AND join_date >= ?', uid, Time.now.utc.at_beginning_of_month.to_date).any?
  end
end
