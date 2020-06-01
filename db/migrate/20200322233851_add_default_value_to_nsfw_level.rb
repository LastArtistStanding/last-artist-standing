# frozen_string_literal: true

class AddDefaultValueToNsfwLevel < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :nsfw_level, from: nil, to: 1
    change_column_default :submissions, :nsfw_level, from: nil, to: 1

    User.where(nsfw_level: nil).update_all(nsfw_level: 1)
    Submission.where(nsfw_level: nil).update_all(nsfw_level: 1)
    Challenge.where(nsfw_level: nil).update_all(nsfw_level: 1)
    Badge.where(nsfw_level: nil).update_all(nsfw_level: 1)

    change_column :users, :nsfw_level, :integer, null: false
    change_column :submissions, :nsfw_level, :integer, null: false
    change_column :challenges, :nsfw_level, :integer, null: false
    change_column :badges, :nsfw_level, :integer, null: false
  end
end
