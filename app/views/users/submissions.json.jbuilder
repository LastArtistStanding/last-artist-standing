# frozen_string_literal: true

json._links do
  json.self { json.href user_submissions_path(@user) }
  json.user { json.href user_path(@user) }
end

json._embedded do
  # FIXME: The submission preview doesnt' need to include user information!
  json.submissions @user.submissions, partial: 'submissions/submission_preview', as: :submission
end
