json.extract! user_feedback, :id, :title, :body, :created_at, :updated_at
json.url user_feedback_url(user_feedback, format: :json)
