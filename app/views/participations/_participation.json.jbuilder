# frozen_string_literal: true

json._links do
  json.self do
    json.href challenge_participation_path(participation.challenge_id, participation.user_id)
  end
  json.challenge { json.href challenge_path(participation.challenge_id) }
  json.user { json.href user_path(participation.user_id) }
end

json._embedded do
  json.user { json.partial! 'users/user_card', user: participation.user }
end

json.call(participation, :created_at, :updated_at, :start_date)

if participation.challenge.started?
  json.call(participation, :active, :score, :eliminated, :end_date)
end
