class HousesController < ApplicationController
  before_action :ensure_moderator, only: %i[new create]

  def index
    @current_houses = House.all
  end

  def new
    @house = House.new
  end

  def create
    # todo stuff:
    @house = House.new(house_params)

    unless @house.house_name?
      @house.errors.add(:house_name, 'House name cannot be empty.')
    end

    unless @house.house_start > Time.now.utc
      @house.errors.add(:house_start, 'Houses cannot begin in the past')
    end

    unless @house.house_start.day == 1
      @house.errors.add(:house_start, 'Houses must start on the first of the month.')
    end

    dnm = [31, @house.house_start.year % 4 == 0 ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][@house.house_start.month - 1]

    unless (@house.house_end - @house.house_start)/3600/24 + 1 == dnm
      @house.errors.add(:house_end, 'Houses must be 1 calendar month long.')
    end

    p @house.errors
    respond_to do |format|
      if @house.errors.any?
        format.html {render :new}
      else
        @house.save
        format.html { redirect_to '/houses' }
      end
    end
  end

  private
  def house_params
    params.require(:house).permit(:house_name, :house_start, :house_end)
  end
end
