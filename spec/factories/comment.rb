# frozen_string_literal: true

# Factory for comments
FactoryBot.define do
  factory :comment, class: 'Comment' do
    association :user

    trait :submission_comment do
      source_type { 'Submission' }
      source_id { create(:submission).id }
    end

    trait :thread_comment do
      source_type { 'Discussion' }
      source_id { create(:discussion).id }
    end

    trait :soft_deleted do
      soft_deleted { true }
      soft_deleted_by { user_id }
    end

    body { 'Sample body' }

  end
end
