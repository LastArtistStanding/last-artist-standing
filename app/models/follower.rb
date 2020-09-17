# frozen_string_literal: true

# Class for the follower db entry
class Follower < ApplicationRecord
  belongs_to :follower_user, :class_name => 'User'
  belongs_to :followed_user, :class_name => 'User'
end
