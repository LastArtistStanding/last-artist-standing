# frozen_string_literal: true

json._links do
  json.self { json.href challenges_path }
end

json._embedded do
  json.challenges @challenges do |challenge|
    json.partial! 'challenges/challenge', challenge: challenge
  end
end
