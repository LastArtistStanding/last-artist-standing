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
    
    def postfrequencyToString(postfrequency)
        
    end
    
    def getUserDADFrequency(user)
        if !user.new_frequency.blank?
            postfrequency = user.new_frequency
        elsif !user.dad_frequency.blank?
            postfrequency = user.dad_frequency
        else
            postfrequency = "None"
        end
        
        case postfrequency
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
    
end
