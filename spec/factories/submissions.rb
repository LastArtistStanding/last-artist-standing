# frozen_string_literal: true

FactoryBot.define do
  factory :submission, class: 'Submission' do
    association :user
    drawing do
      Rack::Test::UploadedFile.new(Rails.root.join('app/assets/images/lastan_1.png'), 'image/png')
    end
    nsfw_level { 1 }
  end
end
