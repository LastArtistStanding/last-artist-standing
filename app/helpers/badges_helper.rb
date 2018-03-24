module BadgesHelper
    
    def getBadgeImage(id)
        currentBadge = Badge.find_by(id: id)
        if currentBadge.nil?
            ""
        else
            if currentBadge.direct_image.present?
                currentBadge.direct_image
            else
                currentBadge.avatar.avatar.url
            end
        end
    end
    
end
