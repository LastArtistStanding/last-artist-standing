# frozen_string_literal: true

# Controller for houses
class HousesController < ApplicationController
  include HousesHelper
  before_action :ensure_moderator, only: %i[edit update]

  # @function index
  # @abstract sets up parameters for the houses main page
  def index
    @date = Date.parse(sane_date&.concat('-01') || Time.now.utc.strftime('%Y-%m-01'))
    @houses = House.where('house_start = ?', @date).sort_by { |h| -h.total }
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
        format.html { redirect_to '/houses' }
      else
        format.html { render :edit }
      end
    end
  end

  # @function join
  # @abstract allows users to join houses
  # @note users cannot join if they are in another house
  # if the house is unbalanced, or the house is old
  def join
    house = House.find(params[:id])
    respond_to do |format|
      if house.add_user(current_user.id)
        flash[:success] = "You've joined #{house.house_name}!"
      else
        flash[:error] = 'You cannot join this house.'
      end
      format.html { redirect_to '/houses' }
    end
  end

  private

  # @function house_params
  # @abstract requires the house parameter and allows the house_name parameter for :edit
  def house_params
    params.require(:house).permit(:house_name)
  end

  # @function sane_date
  # @abstract this is because the date selectors for rails suck.
  def sane_date
    return params[:date] unless params[:date].is_a?(ActionController::Parameters)

    params[:date] = params[:date][:year] + '-' + params[:date][:month]
  end
end
