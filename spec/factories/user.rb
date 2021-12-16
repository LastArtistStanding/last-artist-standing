# frozen_string_literal: true

# Factory for the User class
FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "test-#{n}" }
    sequence(:email) { |n| "test-#{n}@email.com" }
    password { 'password' }
    verified { true }

    trait :marked_for_death do
      marked_for_death { true }
    end

    trait :mod_applicant do
      moderator_application
    end

    trait :moderator do
      is_moderator { true }
    end
  end
end
