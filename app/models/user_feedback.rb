# frozen_string_literal: true

# UserFeedback model
class UserFeedback < ApplicationRecord
  belongs_to :user
end
