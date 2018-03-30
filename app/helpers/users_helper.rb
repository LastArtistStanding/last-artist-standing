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
    
end
