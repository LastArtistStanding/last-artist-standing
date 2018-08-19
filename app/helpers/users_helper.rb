module UsersHelper
    
    def getUserThumb(user)
        if !user.avatar.nil?
            userThumb = user.avatar.thumb.url
        end
        if userThumb.blank?
            userThumb = "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Default+User+Thumb.png"
        end
        
        userThumb
    end
    
    def getUserNsfwLevel(user)
        if user.nsfw_level.blank?
            1
        end
        user.nsfw_level
    end
    
    def getUserDADFrequency(user)
        if !user.new_frequency.blank?
            postfrequency = user.new_frequency
        elsif !user.dad_frequency.blank?
            postfrequency = user.dad_frequency
        else
            postfrequency = 0
        end
    end
    
    def getUserCurrentDADScore(user)
        participation = Participation.find_by({:user_id => user.id, :active => true, :challenge_id => 1})
        if participation.blank?
            "None"
        else
            participation.score
        end
    end
    
    def getUserScoreByChallenge(user, challenge)
        if user.blank? || challenge.blank?
            return 0
        end
        participation = Participation.find_by({:user_id => user.id, :challenge_id => challenge.id})
        if participation.blank?
            0
        else
            participation.score
        end
    end
    
    def getUserMaxLevel(user)
        if user.blank?
            return 0
        end
        award = Award.find_by({:user_id => user.id, :badge_id => 1})
        if award.blank?
            0
        else
            award.prestige
        end
    end
    
end
