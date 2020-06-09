# frozen_string_literal: true

json._links do
  json.self { json.href challenge_path(challenge) }
end

json.call(challenge, :id, :name, :nsfw_level)

# So that an icon for the challenge can be displayed if desired.
json.badge do
  badge = challenge.badge
  json.call(badge, :name, :nsfw_level)
  json.avatar { json.avatar badge.avatar.url }
end
