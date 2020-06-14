# frozen_string_literal: true

# User information which is always going to be relevant when viewing a comment or submission,
# plus some other stuff that could be used to show off (e.g. streak).

json._links do
  json.self { json.href user_path(user) }
end

json.call(user, :id, :created_at, :current_streak, :longest_streak, :highest_level)
json.avatar { json.avatar user.avatar.avatar.url }
json.current_streak user.current_streak
freq = user.current_dad_frequency
json.dad_frequency(freq.nil? || freq.zero? ? nil : freq)
json.username user.username
