# frozen_string_literal: true

FactoryBot.define do
  factory :application, class: ModeratorApplication do
    user
    time_zone { 'America/Los_Angeles' }
    active_hours { 'Placeholder' }
    why_mod { 'Placeholder' }
    past_experience { 'Placeholder' }
    how_long { 'Placeholder' }
    why_dad { 'Placeholder' }
    anything_else { 'Placeholder' }
  end
end
