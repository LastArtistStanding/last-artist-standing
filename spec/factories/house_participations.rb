# frozen_string_literal: true
#
FactoryBot.define do
  factory :house_participation, class: 'HouseParticipation' do
    house_id { 1 }
    user_id { 1 }
    join_date { Time.now.utc.to_date }
    score { 0 }
  end
end
