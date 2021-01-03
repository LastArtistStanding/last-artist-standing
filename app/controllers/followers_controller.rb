# frozen_string_literal: true

# Controller for handling followers
class FollowersController < ApplicationController
  before_action :ensure_authenticated, only: %i[follow unfollow]
  include SessionsHelper

  def follow
    Follower
      .where({ user_id: current_user.id, following: User.find(params[:id]) })
      .first_or_create
    redirect_back(fallback_location:  user_path(params[:id]))
  end

  def unfollow
    Follower.where({ user_id: current_user.id, following: User.find(params[:id]) })
        &.first
        &.destroy
    redirect_back(fallback_location: user_path(params[:id]))
  end
end
