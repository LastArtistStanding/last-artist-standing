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
    old_house_name = @house.house_name
    respond_to do |format|
      if @house.update(house_params)
        log_update(old_house_name)
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
      if (reason = house.add_user(current_user.id)).blank?
        flash[:success] = "You've joined #{house.house_name}!"
      else
        flash[:error] = "You cannot join this house because #{reason}."
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

  def mod_params
    params.require(:reason).permit(:reason)
  end

  # @function sane_date
  # @abstract this handles the date_selector returning a hash rather than a string
  # If the user uses the dropdown, it converts the date hash to a string.
  # If the user uses the buttons or doesn't pass anything, it just uses the string or nothing.
  def sane_date
    return params[:date] unless params[:date].is_a?(ActionController::Parameters)

    params[:date] = params[:date][:year] + '-' + params[:date][:month]
  end

  # @function log_update
  # creates a moderator log when a house is updatedf
  # @param old_house_name - the old name of the house
  def log_update(old_house_name)
    ModeratorLog.create do |log|
      log.user_id = current_user.id
      log.target = @house
      log.action = "#{current_user.username} has changed the name of #{old_house_name}" \
                   " to #{house_params[:house_name]}"
      log.reason = mod_params[:reason]
    end
  end
end
