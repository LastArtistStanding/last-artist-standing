module ChallengesHelper
  def challenge_creator_link(id)
    return "Site Challenge" unless id.present?

    return "User Account Deleted" if id == -1
    
    user = User.find(id)
    link_to(user.username, user)
  end
  
  # TODO: This suite of methods is absolutely fucking awful.
  # Will be removed once the challenge page is refactored.
  def getBadgeThreshold(challenge)
    BadgeMap.where(:challenge_id => challenge.id).order("required_score ASC").first.required_score
  end
    
  def getParticipationLevel(participation, challenge)
    if participation.blank?
      0
    elsif participation.score >= getBadgeThreshold(challenge)
      2
    else
      1
    end
  end
    
  def getUserParticipationLevel(user, challenge, active)
    return 0 if user.nil?
  
    if active
      participation = Participation.find_by(:user_id => user.id, :challenge_id => challenge.id, :active => true)
    else
      participation = Participation.find_by(:user_id => user.id, :challenge_id => challenge.id)
    end
    
    getParticipationLevel(participation, challenge)
  end
  # End absolute fucking garbage.
end
