# frozen_string_literal: true

json._links do
  json.self { json.href challenge_participations_path(@challenge) }
  json.challenge { json.href challenge_path(@challenge) }
end

json._embedded do
  json.challenge { json.partial! 'challenges/challenge_preview', challenge: @challenge }
  json.participations @challenge.participations, partial: 'participation', as: :participation
end
