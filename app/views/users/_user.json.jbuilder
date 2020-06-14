# frozen_string_literal: true

json._links do
  json.self { json.href user_path(user) }
  json.awards { json.href user_awards_path(user) }
  # TODO: Also include challenge participations relationship.
  json.submissions { json.href user_submissions_path(user) }
end

json._embedded do
  json.awards do
    json.partial! 'awards/user_awards', user: user
  end
end

json.call(user, :id, :created_at, :updated_at, :longest_streak, :highest_level)

json.avatar { json.partial! 'application/image', image: user.avatar }

# TODO: This should be 0 if the user has submitted but it hasn't been processed yet,
#   and null if the user has no active streak whatsoever.
json.current_streak user.current_streak

# TODO: This is the check used in `_usercard.html.slim`, but is it necessary?
#   Is there some opportunity to clean up the model/schema here?
freq = user.current_dad_frequency
json.dad_frequency(freq.nil? || freq.zero? ? nil : freq)

# TODO: Remove `user.name` so that this is the *only* meaningful name data.
#   I certainly don't plan on using it in any API-using app.
#   To my understanding, it's currently only used for S3 upload urls
#   (which should be using user ids anyway.
json.username user.username
