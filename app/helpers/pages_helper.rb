module PagesHelper
    
    def dateToString(date)
        if date.nil?
            "None"
        else
            date.strftime("%D")
        end
    end
    
    def postfrequencyToString(postfrequency)
        case postfrequency
        when -1
            "Custom"
        when 1
            "Daily"
        when 2
            "Every Other Day"
        when 7
            "Weekly"
        when 0
            "None"
        else
            "Every #{postfrequency} Days"
        end
    end
    
    def getCurrentDateTime
        Time.now
    end
    
    def userSubmittedToDAD
        # -1, not participating or logged in, display nothing
        if !logged_in?
            return [-1,0]
        end
        
        currentParticipation = Participation.find_by(:active => true, :challenge_id => 1, :user_id => current_user.id)
        if currentParticipation.blank?
            return [-1,0]
        end
        
        challengeEntries = ChallengeEntry.where("challenge_id = :challengeId AND user_id = :userId AND created_at >= :last_date AND created_at < :next_date", {challengeId: 1, userId: current_user.id, last_date: currentParticipation.last_submission_date, next_date: currentParticipation.next_submission_date})
        daysToNextSubmission = currentParticipation.next_submission_date - Date.current
        
        if challengeEntries.count > 0
            return [1,daysToNextSubmission.to_i]
        else
            return [0,daysToNextSubmission.to_i]
        end
    end
    
    def getLatestSeasonalChallenges
        seasonalChallenges = Challenge.where(:seasonal => true).order("start_date ASC")
        seasonCount = seasonalChallenges.count
        #spring
        baseIndex = (seasonCount - 1) - ((seasonCount - 1) % 4)
        if seasonCount > 0
            spring = seasonalChallenges[baseIndex]
        else
            spring = nil
        end
        if seasonCount > 1
            baseIndex += 1
            if baseIndex >= seasonCount
                baseIndex -= 4
            end
            summer = seasonalChallenges[baseIndex]
        else
            summer = nil
        end
        if seasonCount > 2
            baseIndex += 1
            if baseIndex >= seasonCount
                baseIndex -= 4
            end
            autumn = seasonalChallenges[baseIndex]
        else
            autumn = nil
        end
        if seasonCount > 3
            baseIndex += 1
            if baseIndex >= seasonCount
                baseIndex -= 4
            end
            winter = seasonalChallenges[baseIndex]
        else
            winter = nil
        end
        [spring,summer,autumn,winter]
    end
    
end
