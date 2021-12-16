# frozen_string_literal: true

FactoryBot.define do
  factory :house_participation, class: 'HouseParticipation' do
    association :user
    association :house
    join_date { Time.now.utc.to_date }
    score { 0 }
  end
end
