module PagesHelper
    
    def dateToString(date)
        if date.nil?
            "None"
        else
            date.strftime("%B %-d, %Y")
        end
    end
    
    def dateToShortString(date)
        if date.nil?
            "None"
        elsif date.year == Date.current.year
            date.strftime("%b %-d")
        else
            date.strftime("%b %-d, %Y")
        end
    end
    
    def postfrequencyToString(postfrequency, phrase)
        case postfrequency
        when -1
            phrase ? "Custom Frequency" : "Custom"
        when 1
            phrase ? "Posts Daily" : "Daily"
        when 2
            phrase ? "Posts Every Other Day" : "Every Other Day"
        when 7
            phrase ? "Posts Weekly" : "Weekly"
        when 0
            phrase ? "Inactive" : "None"
        else
            phrase ? "Posts Every #{postfrequency} Days" : "Every #{postfrequency} Days"
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
        seasonalChallenges = Challenge.where("seasonal = true AND :todays_date >= start_date", {todays_date: Date.current}).order("start_date ASC")
        seasonCount = seasonalChallenges.count
        #spring
        baseIndex = (seasonCount - 1) - ((seasonCount - 1) % 4)
        if seasonCount > 1
            if baseIndex == (seasonCount - 1)
                baseIndex -= 4
            end
            spring = seasonalChallenges[baseIndex]
        else
            spring = nil
        end
        if seasonCount > 2
            if baseIndex == (seasonCount - 2)
                baseIndex -= 4
            end
            summer = seasonalChallenges[baseIndex + 1]
        else
            summer = nil
        end
        if seasonCount > 3
            if baseIndex == (seasonCount - 3)
                baseIndex -= 4
            end
            autumn = seasonalChallenges[baseIndex + 2]
        else
            autumn = nil
        end
        if seasonCount > 4
            if baseIndex == (seasonCount - 4)
                baseIndex -= 4
            end
            winter = seasonalChallenges[baseIndex + 3]
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
    
    def getRandomSafeSubmission
        safeSubmission = Submission.where("nsfw_level = 1 and created_at >= ?", Time.now - 14.days).sample
        if safeSubmission.blank? || safeSubmission.drawing.blank?
            nil
        else
            safeSubmission
        end
    end
    
    def getLatestSubmission
        Submission.last
    end
    
    def cluster
        cluster = []
        each do |element|
            if cluster.last && yield(cluster.last.last) == yield(element)
                cluster.last << element
            else
                cluster << [element]
            end
        end
        cluster
    end
    
    def html_escape(text)
        text.gsub! '&','%amp;'
        text.gsub! '<','&lt;'
        text.gsub! '>','&gt;'
        text.gsub! '\"','&quot;'
        text.gsub! '\'','&#39;'
        text.gsub! /\r\n/,'<br>'
        text
    end
    
end
