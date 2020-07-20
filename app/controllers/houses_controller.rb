# frozen_string_literal: true

# Controller for plotting LAS Houses times
class HousesController < ApplicationController
  def index
    @user_list = {}
    # TODO: Users.where('house_id is not null').each do |user|
    User.where("1 = 1").each do |user|
      @user_list[user[:name]] = 0
      Submission.where("user_id = ? and created_at >= ?", user[:id], Date.today - 30.days).each do |s|
        @user_list[user[:name]] += s[:time].to_f / 60.0
      end
    end
    @total_time = @user_list.values.sum
    @user_list = @user_list.delete_if { |_k, v| !v.positive? }.sort_by { |hash| -hash.last }
  end
end
