# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

FactoryBot.find_definitions

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    fixtures :all

    def logged_in?
      !session[:user_id].nil?
    end
  end
end
