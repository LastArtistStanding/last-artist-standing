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
    
end
