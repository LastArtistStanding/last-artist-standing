# frozen_string_literal: true

# Controller for houses
class HousesController < ApplicationController
  include HousesHelper
  before_action :ensure_moderator, only: %i[edit update]
  before_action :ensure_unbanned, only: %i[join]

  # @function index
  # @abstract sets up parameters for the houses main page
  def index
    @date = Date.parse(params[:date]&.values&.join('-') || Time.now.utc.strftime('%Y-%m-01'))
    @houses = House.where(house_start: @date.at_beginning_of_month.to_date).sort_by { |h| -h.total }
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
    if mod_params[:reason].blank?
      @house.errors.add(:base, 'Must specify a reason.')
      render :edit
    else
      old_house_name = @house.house_name
      @house.update(house_params)
      log_update(old_house_name)
      redirect_to '/houses'
    end
  end

  # @function join
  # @abstract allows users to join houses
  # @note users cannot join if they are in another house
  # if the house is unbalanced, or the house is old
  def join
    house = House.find(params[:id])
    if (reason = house.add_user(current_user.id)).is_a?(HouseParticipation)
      flash[:success] = "You've joined #{house.house_name}!"
    else
      flash[:error] = "You cannot join this house because #{reason}."
    end
    redirect_to '/houses'
  end

  private

  # @function house_params
  # @abstract requires the house parameter and allows the house_name parameter for :edit
  def house_params
    params.require(:house).permit(:house_name, :reason, :date)
  end

  def mod_params
    params.require(:reason).permit(:reason)
  end

  # @function log_update
  # creates a moderator log when a house is updated
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
