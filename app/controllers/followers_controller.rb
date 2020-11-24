# frozen_string_literal: true

# Controller for handling followers
class FollowersController < ActionController::Base
  include SessionsHelper

  def follow
    if Follower.where({ user_id: current_user&.id, following: User.find(params[:id]) }).empty?
      Follower.create(user_id: current_user&.id, following: User.find(params[:id]))
    end

    redirect_back(fallback_location: root_path)
  end

  def unfollow
    Follower.where({ user_id: current_user&.id, following: User.find(params[:id]) })
        &.first
        &.destroy
    redirect_back(fallback_location: root_path)
  end
end
