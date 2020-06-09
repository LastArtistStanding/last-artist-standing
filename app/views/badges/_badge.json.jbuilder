# frozen_string_literal: true

# IDs and update times should be reserved for models which can
# be meaningfully referenced and updated independently of other models.

# Badges have a 1:1 relationship with challenges. They do not need a unique id,
# and updating them should be considered updating the challenge (?).
# Or, at the very least, that's true the way things are currently;
# if that ever changes, badges should recieve *their own API endpoint*
# (even if they continue to be _embedded into this particular view)
# FIXME: The actual model should also behave this way to prevent this assumption
#   from causing issues later.
json.call(badge, :name, :nsfw_level)
json.avatar { json.partial! 'application/image', image: badge.avatar }
json.maps badge.badge_maps, partial: 'badge_maps/badge_map', as: :badge_map
