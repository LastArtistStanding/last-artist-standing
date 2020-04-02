# frozen_string_literal: true

# Helper functions for views that leverage badges.
module BadgesHelper
  NSFW_AVATAR = 'https://s3.us-east-2.amazonaws.com/do-art-daily-public/Missing+Image+Avatar.jpg'

  def safe_badge_avatar(badge)
    unless logged_in?
      return NSFW_AVATAR if badge.nsfw_level > 1

      return badge.avatar_url
    end

    return NSFW_AVATAR if current_user.nsfw_level < badge.nsfw_level

    badge.avatar_url
  end
end
