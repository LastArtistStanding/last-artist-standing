# frozen_string_literal: true

FactoryBot.define do
  factory :moderator_application, class: 'ModeratorApplication' do
    association :user
    time_zone { 'Pacific Time (US & Canada)' }
    active_hours { 'Placeholder' }
    why_mod { 'Placeholder' }
    past_experience { 'Placeholder' }
    how_long { 'Placeholder' }
    why_dad { 'Placeholder' }
    anything_else { 'Placeholder' }
  end
end
