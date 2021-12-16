# frozen_string_literal: true

# Factory for Notifications class
FactoryBot.define do
  factory :notification do
    association :user

    trait :challenge_notification do
      association :source, factory: :challenge
      source_type { 'Challenge' }
    end

    trait :comment do
      association :source, factory: :comment
      source_type { 'Comment' }
    end
  end
end
