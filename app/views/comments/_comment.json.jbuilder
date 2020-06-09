# frozen_string_literal: true

json._links do
  json.self { json.href comment_path(comment) }
  json.source { json.href url_for(comment.source) }
  json.user { json.href user_path(comment.user_id) }
end

json._embedded do
  # User information which is always going to be relevant when viewing a comment,
  # plus some other stuff that could be used to show off (e.g. streak).
  json.user { json.partial! 'users/user_card', user: comment.user }
end

json.call(comment, :id, :body, :created_at, :updated_at)
