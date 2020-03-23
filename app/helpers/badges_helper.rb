module BadgesHelper
  NSFW_AVATAR_OVERRIDE = "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Missing+Image+Avatar.jpg"

  def safe_avatar(badge)
    if !logged_in?
      return NSFW_AVATAR_OVERRIDE if badge.nsfw_level > 1
      
      return badge.avatar_url
    end

    return NSFW_AVATAR_OVERRIDE if current_user.nsfw_level < badge.nsfw_level
    
    badge.avatar_url
  end
end
