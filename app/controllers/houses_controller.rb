class HousesController < ApplicationController
  def index
    @user_list = {}
    @total_time = 0
    # TODO: Users.where('house_id is not null').each do |user|
    User.all.each do |user|
      sum = 0
      Submission.where('user_id = ? and created_at >= ?', user.id, Date.today - 30.days).each do |submission|
        sum += submission.time / 60.0
        @total_time += submission.time / 60.0
      end
      @user_list[user.name] = sum if sum.positive?
    end
    @user_list = @user_list.sort_by { |hash| -hash.last }
  end
end
