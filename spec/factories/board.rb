# frozen_string_literal: true

# Factory for boards
FactoryBot.define do
  factory :board, class: 'Board' do
    sequence(:title) { |n| "Test#{n}" }
    sequence(:alias) { |n| "test#{n}" }
    permission_level { 3 }
  end
end
