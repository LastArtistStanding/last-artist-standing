module BadgesHelper
    
    def getBadgeImage(badge)
        if badge.direct_image.present?
            badgeImage = badge.direct_image
        elsif !badge.avatar.nil?
            badgeImage = badge.avatar.avatar.url
        end
        if badgeImage.blank?
            badgeImage = "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Missing+Image+Avatar.jpg"
        end
        
        badgeImage
    end
    
end
