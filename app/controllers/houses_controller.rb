# frozen_string_literal: true

# Controller for houses
class HousesController < ApplicationController
  include HousesHelper
  before_action :ensure_moderator, only: %i[edit update]

  # @function index
  # @abstract sets up paramaters for the houses main page
  def index
    @date = params[:date].present? ? Date.parse(params[:date][:year] + "-" + params[:date][:month] + "-01") : Time.now.utc.at_beginning_of_month.to_date
    @houses = House.where("house_start = ?", @date).sort_by { |h| -h.total_score }
  end

  # @function edit
  # @abstract returns house to edit for the edit view
  # @note requires moderator attribute
  def edit
    @house = House.find(params[:id])
  end

  # @function update
  # @abstract updates the house with a new name
  # @note requires moderator attribute
  def update
    @house = House.find(params[:id])
    respond_to do |format|
      if @house.update(house_params)
        format.html { redirect_to "/houses" }
      else
        format.html { render :edit }
      end
    end
  end

  # @function join
  # @abstract allows users to join houses
  # @note users cannot join if they are in another house, if the house is unbalanced, or the house is old
  def join
    house = House.find(params[:id])
    respond_to do |format|
      if house.add_user(current_user.id)
        flash[:success] = "You've joined #{house.house_name}!"
      else
        flash[:error] = "You cannot join this house."
      end
      format.html { redirect_to "/houses" }
    end
  end


  private

  # @function house_params
  # @abstract requires the house parameter and allows the house_name parameter for :edit
  def house_params
    params.require(:house).permit(:house_name)
  end
end
