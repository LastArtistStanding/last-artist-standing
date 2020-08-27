class HousesController < ApplicationController
  include HousesHelper
  before_action :ensure_moderator, only: %i[edit update]

  def index
    @old_houses = House.where('house_start = ?', Time.now.utc.prev_month.at_beginning_of_month).sort_by { |h| -h.total_score }
    @current_houses = House.where('house_start = ?', Time.now.utc.at_beginning_of_month.to_date).sort_by { |h| -h.total_score }
  end

  def edit
    @house = House.find(params[:id])
  end

  def update
    @house = House.find(params[:id])
    respond_to do |format|
      if @house.update(house_params)
        format.html { redirect_to '/houses' }
      else
        format.html { render :edit }
      end
    end
  end

  def join
    @house = House.find(params[:id])
    if @house.nil?
      render_not_found
    elsif is_in_a_house?
      render_unauthorized
    else
      respond_to do |format|
        # add the last 10 days of submissions if they are joining late in the month
        search_date = (Time.now.utc.to_date - @house.house_start).to_i > 10 ? Time.now.utc.to_date - 10 : @house.house_start
        time_spent = 0
        current_user.submissions.where("created_at >= ?", search_date).each do |s|
          time_spent += s.time.to_i / 30
        end
        HouseParticipation.create(user_id: current_user.id, house_id: params[:id], join_date: Time.now.utc.to_date, time_spent: time_spent)
        flash[:success] = "You've joined #{@house.house_name}!"
        format.html { redirect_to '/houses' }
      end
    end
  end


  private

  def house_params
    params.require(:house).permit(:house_name, :house_start, :joinable)
  end
end
