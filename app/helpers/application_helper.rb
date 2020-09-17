# frozen_string_literal: true

module ApplicationHelper
  include SessionsHelper

  def follows?(follower_id)
    return false unless logged_in?

    Follower.where({ follower_user_id: current_user&.id, followed_user_id: follower_id }).any?
  end
end
