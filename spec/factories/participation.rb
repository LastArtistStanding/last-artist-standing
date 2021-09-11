# frozen_string_literal: true

# Factory for Participation class
FactoryBot.define do
  factory :participation do
    association :user
    association :challenge
    score { 0 }
    start_date { Time.now.utc }
    end_date { Time.now.utc + 10.days }
  end
end
