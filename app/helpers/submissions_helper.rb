module SubmissionsHelper
    
    def getNsfwString(level)
        case level
        when 1
            "Safe"
        when 2
            "Questionable"
        when 3
            "Explicit"
        else
            "???"
        end
    end
    
    def getSubmissionThumb(submission)
        if !logged_in? || current_user.nsfw_level.blank?
            if submission.nsfw_level > 1
                "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Content+Filter+Thumb.png"
            else
                if submission.drawing.blank?
                    ""
                else
                    submission.drawing.thumb.url
                end
            end
        elsif current_user.nsfw_level < submission.nsfw_level
            "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Content+Filter+Thumb.png"
        else
            if submission.drawing.blank?
                ""
            else
                submission.drawing.thumb.url
            end
        end
    end
    
    def getSubmissionAvatar(submission)
        if !logged_in? || current_user.nsfw_level.blank?
            if submission.nsfw_level > 1
                "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Content+Filter+Avatar.png"
            else
                if submission.drawing.blank?
                    ""
                else
                    submission.drawing.avatar.url
                end
            end
        elsif current_user.nsfw_level < submission.nsfw_level
            "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Content+Filter+Avatar.png"
        else
            if submission.drawing.blank?
                ""
            else
                submission.drawing.avatar.url
            end
        end
    end
    
    def getSubmissionTimeText(submission)
        if submission.time.blank?
            "unspecified"
        else
            "#{submission.time} minutes"
        end
    end
    
    def getSubmissionTitle(submission)
        if submission.title.blank?
            "Untitled"
        else
            submission.title
        end
    end
    
    def getSubmissionDescription(submission)
        if submission.description.blank?
            "No description provided."
        else
            submission.description
        end
    end
    
end
