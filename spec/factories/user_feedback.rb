# frozen_string_literal: true

# Factory for the User feedback
FactoryBot.define do
  factory :user_feedback do
    association :user
    title { 'Test Title' }
    body { 'Test Body' }
  end
end

