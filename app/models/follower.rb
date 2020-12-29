# frozen_string_literal: true

# Class for the follower db entry
class Follower < ApplicationRecord
  belongs_to :user, class_name: 'User'
  belongs_to :following, class_name: 'User'
end
