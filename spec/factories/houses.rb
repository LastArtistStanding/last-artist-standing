# frozen_string_literal: true

FactoryBot.define do
  factory :house, class: 'House' do
    sequence(:house_name) { |n| "House #{n}" }
    house_start { Time.now.utc.at_beginning_of_month.to_date }
  end
end
