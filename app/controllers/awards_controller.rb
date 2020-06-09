# frozen_string_literal: true

class AwardsController < ApplicationController
  before_action :set_user, only: %i[index show]
  before_action :set_award, only: %i[show]

  def index
    respond_to do |format|
      format.html { redirect_to "#{user_path(@user)}#awards", status: :see_other }

      format.json do
        @awards = Award.where(user_id: @user.id)
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        redirect_to "#{user_path(@user)}#awards", status: :see_other
      end

      format.json do
        @badge = Badge.find(@award.badge_id)
      end
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])

    render_not_found if @user.nil?
  end

  def set_award
    @award = Award.find_by(user_id: @user.id, badge_id: params[:badge_id])

    render_not_found if @award.nil?
  end
end
