# frozen_string_literal: true

json._links do
  json.self { json.href user_award_path(award.user_id, award.badge_id) }
  # I can't link directly to the badge or badge_map, because neither has its own endpoint.
  json.challenge { json.href challenge_path(award.badge.challenge_id) }
  json.user { json.href user_path(award.user_id) }
end

# An award is useless without information about its badge, so include it here.
# We only want to include the strictly relevant information, i.e. the badge itself,
# and the badge map associated with the award this user actually has.
json._embedded do
  json.challenge do
    json._links do
      json.self { json.href challenge_path(award.badge.challenge_id) }
    end

    json.call(award.challenge, :name, :nsfw_level)

    json.badge do
      badge = award.badge
      json.call(badge, :name, :nsfw_level)
      json.avatar badge.avatar_url

      # Only include information about the badge_map for the award this user actually has.
      if award.badge_map
        json.maps [award.badge_map], partial: 'badge_maps/badge_map', as: :badge_map
      end
    end
  end
end

json.call(award, :prestige, :date_received)
