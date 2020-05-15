# frozen_string_literal: true

FactoryBot.define do
  factory :challenge do
    name { 'Challenge' }
    description { 'A challenge.' }
    association :creator_id, factory: :user
    postfrequency { 1 }
    start_date { Time.now.utc.to_date + 10 }
    end_date { Time.now.utc.to_date + 30 }
  end
end
