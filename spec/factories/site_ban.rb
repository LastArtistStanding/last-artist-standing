# frozen_string_literal: true

FactoryBot.define do
  factory :site_ban, class: 'SiteBan' do
    association :user
    expiration { 10.days.from_now }
    reason { 'some ban reason' }
  end
end
