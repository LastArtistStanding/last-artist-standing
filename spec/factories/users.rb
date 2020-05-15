# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'Jack' }
    email { 'jack@example.com' }
    password { 'password' }
  end
end
