module BadgesHelper
    
    def getBadgeImage(badge)
        if badge.direct_image.present?
            badge.direct_image
        else
            badge.avatar.avatar.url
        end
    end
    
end
