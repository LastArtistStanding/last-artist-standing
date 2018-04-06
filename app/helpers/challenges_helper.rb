module ChallengesHelper
    
    def getChallengeCreator(id)
        if id.present?
            User.find_by(id: id).name
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
    
end
