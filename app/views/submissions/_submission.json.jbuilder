# frozen_string_literal: true

next_ = next_submission(submission)
prev = prev_submission(submission)
user_next = next_user_submission(submission)
user_prev = prev_user_submission(submission)

json._links do
  json.self { json.href submission_path(submission) }

  if next_.present?
    json.next do
      json.href submission_path(next_)
      json.title "Next submission by #{next_.user.username}"
    end
  end
  if prev.present?
    json.prev do
      json.href submission_path(prev)
      json.title "Previous submission by #{prev.user.username}"
    end
  end
  if user_next.present?
    json.user_next do
      json.href submission_path(user_next)
      json.title "#{submission.user.username}'s Next Submission"
    end
  end
  if user_prev.present?
    json.user_prev do
      json.href submission_path(user_prev)
      json.title "#{submission.user.username}'s Previous Submission"
    end
  end

  # It would also be possible to use `submission.challenges` here,
  # but my philosophy is that the _links section should never require
  # actually loading the linked data from the database
  # (regardless of whether it will end up being loaded by another section).
  json.challenge_entries submission.challenge_entries do |entry|
    json.href challenge_path(entry.challenge_id)
  end
  json.comments { json.href submission_comments_path(submission) }
  json.user { json.href user_path(submission.user_id) }
end

json._embedded do
  json.next { json.partial! 'submissions/submission_preview', submission: next_ } if next_.present?
  json.prev { json.partial! 'submissions/submission_preview', submission: prev } if prev.present?
  if user_next.present?
    json.user_next { json.partial! 'submissions/submission_preview', submission: user_next }
  end
  if user_prev.present?
    json.user_prev { json.partial! 'submissions/submission_preview', submission: user_prev }
  end

  json.challenge_entries submission.challenges,
                         partial: 'challenges/challenge_preview', as: :challenge
  json.comments { json.partial! 'comments/source_comments', source: submission }
  json.user { json.partial! 'users/user_card', user: submission.user }
end

json.call(submission, :id, :time, :nsfw_level, :commentable, :created_at, :updated_at, :is_animated_gif)

# TODO: IMO this would be a better way to handle in the *model* too.
#   `nil` represents an unspecified value more accurately than the empty string.
json.description submission.description.presence
json.title submission.title.presence

json.drawing do
  drawing = submission.drawing

  json.full drawing.url
  json.thumb drawing.thumb.url
  json.avatar drawing.avatar.url
end
