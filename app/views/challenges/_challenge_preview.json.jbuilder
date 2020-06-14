# frozen_string_literal: true

json._links do
  json.self { json.href challenge_path(challenge) }
end

# The start and end date of a challenge typically won't be displayed,
# but are a likely candidate for something to sort by.
json.call(challenge, :id, :name, :created_at, :start_date, :end_date, :nsfw_level)

# So that an icon for the challenge can be displayed if desired.
json.badge do
  badge = challenge.badge
  json.call(badge, :name, :nsfw_level)
  json.avatar { json.avatar badge.avatar.url }
end
