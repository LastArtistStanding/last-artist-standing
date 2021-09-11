# frozen_string_literal: true

# Factory for ChallengeEntry class
FactoryBot.define do
  factory :challenge_entry do
    association :user
    association :challenge
    association :submission
  end
end
