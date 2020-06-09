# frozen_string_literal: true

json._links do
  json.self { json.href user_awards_path(user) }
  json.user { json.href user_path(user) }
end

json._embedded do
  json.awards user.awards, partial: 'awards/award', as: :award
end
