# frozen_string_literal: true

FactoryBot.define do
  factory :badge do
    association :challenge
    name { 'Challenge Badge' }
    avatar { 'image.png' }
    direct_image { 'https://example.com/image.png' }
    created_at { Time.now.utc }
    updated_at { created_at }
  end
end
