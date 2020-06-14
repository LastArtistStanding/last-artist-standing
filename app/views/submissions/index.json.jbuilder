# frozen_string_literal: true

json._links do
  json.self { json.href @self_url }
  json.prev { json.href @prev_url } if @prev_url.present?
  json.next { json.href @next_url } if @next_url.present?
end

json._embedded do
  json.submissions @submissions, partial: 'submission_preview', as: :submission
end
