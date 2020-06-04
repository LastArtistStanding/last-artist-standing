# frozen_string_literal: true

FactoryBot.define do
  factory :badge do
    association :challenge_id, factory: :challenge
    name { 'Challenge Badge' }
    avatar do
      Rack::Test::UploadedFile.new(Rails.root.join('app/assets/images/lastan_1.png'), 'image/png')
    end
    created_at { Time.now.utc }
    updated_at { created_at }
  end
end
