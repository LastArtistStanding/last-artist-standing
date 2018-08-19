module ChallengesHelper
    
    def getChallengeCreator(id)
        if id.present?
            link_to(User.find_by(id: id).name, User.find_by(id: id))
        else
            "Site Challenge"
        end
    end
    
    def userIsInChallenge(user, challenge)
        !Participation.find_by(:user_id => user.id, :challenge_id => challenge.id).blank?
    end
    
    def getDADChallenge
        Challenge.find(1)
    end
    
    def getCurrentSeasonalChallenge
        Challenge.where(":todays_date >= start_date AND :todays_date < end_date AND seasonal = true", {todays_date: Date.current}).first
    end
    
    def getDaysInChallenge(challenge)
        if challenge.blank?
            0
        else
            (challenge.end_date - challenge.start_date).to_i
        end
    end
    
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
        if active
            participation = Participation.find_by(:user_id => user.id, :challenge_id => challenge.id, :active => true)
        else
            participation = Participation.find_by(:user_id => user.id, :challenge_id => challenge.id)
        end
        getParticipationLevel(participation, challenge)
    end
    
    def getParticipationIcon(value)
        case value
        when 0
            "<i class='fa fa-times-circle' aria-hidden='true'></i>"
        when 1
            "<i class='fa fa-check' aria-hidden='true'></i>"
        when 2
            "<i class='fa fa-trophy' aria-hidden='true'></i>"
        end
    end
    
    def getAwardByUserAndChallenge(challenge, user)
        if challenge.blank?
            nil
        elsif user.blank?
            nil
        else
            badge_map = BadgeMap.find_by(challenge_id: challenge.id)
            Award.find_by(:user_id => user.id, :badge_id => badge_map.badge_id)
        end
    end
    
end
