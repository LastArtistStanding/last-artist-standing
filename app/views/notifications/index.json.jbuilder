json.array! @notifications do |notification|
  json.recipient notification.user.username
  json.recipient_id notification.user_id
  json.source notification.source_id
  json.source_type notification.source_type
  json.body notification.body
  json.url notification.url
end