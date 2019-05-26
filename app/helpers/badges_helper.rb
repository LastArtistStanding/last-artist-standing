module BadgesHelper
  def getBadgeImage(badge)
    nsfw_level = badge.nsfw_level
    
    if !logged_in? || current_user.nsfw_level.blank?
      return "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Missing+Image+Avatar.jpg" if nsfw_level > 1
      
      return badgeImageSource(badge)
    end
    
    return "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Missing+Image+Avatar.jpg" if current_user.nsfw_level < nsfw_level
    
    badgeImageSource(badge)
  end
  
  def badgeImageSource(badge)
    return badge.direct_image if badge.direct_image.present?
    
    return badge.avatar.avatar.url if !badge.avatar.nil?
    
    "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Missing+Image+Avatar.jpg"
  end
end
