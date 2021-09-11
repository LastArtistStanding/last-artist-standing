# frozen_string_literal: true

FactoryBot.define do
  factory :challenge do
    sequence(:name) { |n| "Challenge#{n}" }
    description { 'A challenge.' }
    association :creator_id, factory: :user
    postfrequency { 1 }
    start_date { Time.now.utc.to_date + 10 }
    end_date { Time.now.utc.to_date + 30 }
  end

  factory :seasonal_challenge, parent: :challenge do
    sequence(:name) { |n| "Seasonal Challenge#{n}" }
    seasonal { true }
    start_date { Time.now.utc.to_date - 10 }
    end_date { Time.now.utc.to_date + 10 }
  end
end
