json.extract! submission, :id, :drawing, :nsfw_level, :created_at, :updated_at
json.url submission_url(submission, format: :json)

json.set! :user do
  json.set! :id, submission.user.id
  json.set! :name, submission.user.name
  json.set! :avatar, submission.user.avatar
end