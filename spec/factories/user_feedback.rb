# frozen_string_literal: true

# Factory for UserSession class
FactoryBot.define do
  factory :user_feedback do
    association :user
    body { 'Test Body' }
  end
end
