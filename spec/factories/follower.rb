# frozen_string_literal: true

# Factory for Followers class
FactoryBot.define do
  factory :follower do
    association :user
    association :following, factory: :user
  end
end
