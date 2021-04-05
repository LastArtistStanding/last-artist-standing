# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "test-#{n}" }
    sequence(:email) { |n| "test-#{n}@email.com" }
    password { 'password' }
    password_confirmation { 'password' }
    verified { true }
  end
end
