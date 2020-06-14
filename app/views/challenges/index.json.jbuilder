# frozen_string_literal: true

json._links do
  json.self { json.href challenges_path }
end

json._embedded do
  json.challenges @challenges, partial: 'challenges/challenge_preview', as: :challenge
end
