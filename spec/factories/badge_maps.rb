# frozen_string_literal: true

FactoryBot.define do
  factory :badge_map do
    association :badge
    association :challenge
    required_score { 2 }
    prestige { 2 }
    description { 'A challenge\'s badge' }
    created_at { Time.now.utc }
    updated_at { created_at }
  end
end
