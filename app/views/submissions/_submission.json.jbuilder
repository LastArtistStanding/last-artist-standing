json.extract! submission, :id, :drawing, :thumbnail, :nsfw_level, :created_at, :updated_at
json.url submission_url(submission, format: :json)
