# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'Jack' }
    email { 'jack@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    verified { true }
  end
end
