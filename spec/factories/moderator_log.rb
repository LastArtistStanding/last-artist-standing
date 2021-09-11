# frozen_string_literal: true

# Factory for ModeratorLog class
FactoryBot.define do
  factory :moderator_log do
    association :user
    association :target, factory: :user
    action { 'Test action' }
    target_type { 'User' }
    reason { 'Test Reason' }
  end
end
