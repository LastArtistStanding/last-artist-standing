# frozen_string_literal: true

class ParticipationsController < ApplicationController
  before_action :set_challenge, only: %i[index create destroy]
  before_action :ensure_challenge_not_started, only: %i[create destroy]
  before_action :ensure_authenticated, only: %i[create destroy]
  before_action :set_participation, only: %i[show destroy]
  before_action -> { ensure_authorized @participation.user_id }, only: %i[destroy]

  def index
    respond_to do |format|
      format.html do
        redirect_to "#{challenge_path(params[:challenge_id])}#participants", status: :see_other
      end

      format.json do
        render :index
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        redirect_to challenge_participations_path(@participation.challenge_id), status: :see_other
      end

      format.json
    end
  end

  def create
    if Participation.find_by(challenge_id: @challenge.id, user_id: current_user.id).nil?
      Participation.create!(challenge_id: @challenge.id, user_id: current_user.id,
                            score: 0, start_date: @challenge.start_date)
    end

    flash[:success] = "You will now be participating in #{@challenge.name}"
    redirect_to challenge_participation_path(@challenge.id, current_user), status: :see_other
  end

  def destroy
    @participation.destroy!

    flash[:success] = "You will no longer be participating in #{@challenge.name}"
    redirect_to challenge_participations_path(@participation.challenge_id), status: :see_other
  end

  private

  def set_challenge
    @challenge = Challenge.find_by(id: params[:challenge_id])

    render_not_found if @challenge.nil?
  end

  def set_participation
    @participation = Participation.find_by(challenge_id: params[:challenge_id], user_id: params[:user_id])

    render_not_found if @participation.nil?
  end

  def ensure_challenge_not_started
    return unless @challenge.started?

    flash[:danger] = 'You cannot join or leave a challenge which has already started!'
    render_unauthorized
  end
end
