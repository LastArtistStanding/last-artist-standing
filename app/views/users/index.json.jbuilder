# frozen_string_literal: true

json._links do
  json.self { json.href @self_url }
  json.prev { json.href @prev_url } if @prev_url
  json.next { json.href @next_url } if @next_url
end

json._embedded do
  json.users @users, partial: 'user_card', as: :user
end

json.max_id User.maximum(:id)
json.users_count User.count
