# frozen_string_literal: true

#Helper functions for follwers
module FollowersHelper
  include SessionsHelper

  def follows?(follower_id)
    return false unless logged_in?

    Follower.where({ user: current_user&.id, following: follower_id }).any?
  end
end

