# frozen_string_literal: true

# Factory for UserSession class
FactoryBot.define do
  factory :user_session do
    association :user
    ip_address { '127.0.0.1' }
  end
end
