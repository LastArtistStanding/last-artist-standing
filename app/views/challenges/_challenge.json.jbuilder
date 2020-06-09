# frozen_string_literal: true

json._links do
  json.self { json.href challenge_path(challenge) }
  json.creator { json.href user_path(challenge.creator_id) } if challenge.creator_id.present?
  # These could also reasonably be `_embedded`.
  json.entries { json.href challenge_entries_path(challenge) } if challenge.started?
  json.participations { json.href challenge_participations_path(challenge) }
end

json._embedded do
  if challenge.creator.present?
    json.creator { json.partial! 'users/user_card', user: challenge.creator }
  end
end

json.call(challenge,
          # Non-null fields with default values.
          :id, :created_at, :updated_at, :nsfw_level, :seasonal,
          # Non-null fields which must be specified.
          :name, :description, :start_date, :postfrequency, :streak_based,
          # Nullable fields which must be specified.
          :end_date)

json.badge { json.partial! 'badges/badge', badge: challenge.badge }

# FIXME: Although due to how checkbox forms work, this is always true or false in practice,
#   neither the schema, model, or controller prevent it from being null!
json.streak_based challenge.streak_based || false

# FIXME: This should also default to false in the model.
#   Right now, all values are either true or *null*!
json.rejoinable challenge.rejoinable || false
