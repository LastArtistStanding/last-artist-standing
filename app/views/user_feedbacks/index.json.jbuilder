# frozen_string_literal: true

json.array! @user_feedbacks, partial: 'user_feedbacks/user_feedback', as: :user_feedback
