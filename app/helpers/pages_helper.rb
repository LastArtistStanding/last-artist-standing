module PagesHelper
    
    def dateToString(date)
        if date.nil?
            "None"
        else
            date.strftime("%B %-d, %Y")
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
            return [-2,0]
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
    
    def getCurrentSeasonalChallenge
        Challenge.where(":todays_date >= start_date AND :todays_date < end_date AND seasonal = true", {todays_date: Date.current}).first
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
    
    def patchImportanceToString(importance)
        case importance
        when 1
            ""
        when 2
            "<b>[Important]</b> ".html_safe
        when 3
            "<b>[CRITICAL]</b> ".html_safe
        else
            ""
        end
    end
    
    def patchImportanceToClass(importance)
        case importance
        when 1
            "list-group-item-info"
        when 2
            "list-group-item-warning"
        when 3
            "list-group-item-danger"
        else
            ""
        end
    end
    
    def getPatchTitle(patch)
        if patch.blank? || patch.title.blank?
            ""
        else
            " - #{patch.title}"
        end
    end
    
end
