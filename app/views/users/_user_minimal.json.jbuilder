# frozen_string_literal: true

json._links do
  json.self { json.href user_path(user) }
end

json.avatar { json.avatar user.avatar.avatar.url }
json.username user.username
