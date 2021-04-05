# frozen_string_literal: true

# Factory for discussions
FactoryBot.define do
  factory :discussion, class: 'Discussion' do
    association :user
    sequence(:title) { |n| "Thread #{n}" }
    nsfw_level { 1 }
    locked { false }
  end
end
