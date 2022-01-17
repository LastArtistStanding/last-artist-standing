# frozen_string_literal: true

module ChallengesHelper
  def challenge_creator_link(challenge)
    if challenge.creator_id.blank?
      return 'Site Challenge' if challenge.is_site_challenge

      return 'User Account Deleted'
    end

    user = User.find(challenge.creator_id)
    link_to(user.username, user)
  end

  # TODO: This suite of methods is absolutely fucking awful.
  # Will be removed once the challenge page is refactored.
  def getBadgeThreshold(challenge)
    BadgeMap.where(challenge_id: challenge.id).order('required_score ASC').first.required_score
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

    participation = if active
                      Participation.find_by(user_id: user.id, challenge_id: challenge.id,
                                            active: true)
                    else
                      Participation.find_by(user_id: user.id, challenge_id: challenge.id)
                    end

    getParticipationLevel(participation, challenge)
  end
  # End absolute fucking garbage.
end
