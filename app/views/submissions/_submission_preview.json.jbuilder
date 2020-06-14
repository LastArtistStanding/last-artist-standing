# frozen_string_literal: true

# The information we're typically going to care about when previewing entries is:
# the title, the user's name, when it was created and updated, the thumbnail.
# We don't care about e.g. the comments.
json._links do
  json.self { json.href submission_path(submission) }
  json.user { json.href user_path(submission.user_id) }
end

json._embedded do
  json.user { json.partial! partial: 'users/user_minimal', user: submission.user }
end

json.call(submission, :id, :created_at, :nsfw_level, :is_animated_gif)
json.title submission.title.presence

json.drawing { json.partial! 'application/image', image: submission.drawing }
