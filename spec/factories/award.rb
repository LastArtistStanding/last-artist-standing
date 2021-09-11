# frozen_string_literal: true

# Factory for Award class
FactoryBot.define do
  factory :award do
    association :user
    association :badge
    prestige { 1 }
    date_received { Time.zone.now.to_date }
  end
end
