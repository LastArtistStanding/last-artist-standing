# frozen_string_literal: true

class ChallengesController < ApplicationController
  include SubmissionsHelper

  before_action :set_challenge, only: %i[show edit update destroy entries mod_action]
  before_action :ensure_authenticated, only: %i[new create edit update destroy mod_action]
  before_action :ensure_moderator, only: %i[mod_action]
  before_action -> { ensure_authorized @challenge.creator_id }, only: %i[edit update destroy]
  before_action :ensure_unbanned, only: %i[new create edit update destroy]

  def index
    respond_to do |format|
      format.html do
        @activeChallenges = Challenge.where('start_date <= ? AND (end_date > ? OR end_date IS NULL)', Date.current, Date.current).order('start_date ASC, end_date DESC')
        @upcomingChallenges = Challenge.where('start_date > ?', Date.current).order('start_date DESC, end_date DESC')
        @completedChallenges = Challenge.where('end_date <= ?', Date.current).order('start_date DESC, end_date DESC')
        unless logged_in_as_moderator
          @activeChallenges = @activeChallenges.where('soft_deleted = false')
          @upcomingChallenges = @upcomingChallenges.where('soft_deleted = false')
          @completedChallenges = @completedChallenges.where('soft_deleted = false')
        end
      end

      format.json do
        # There aren't a lot of challenges, so until proper search is supported,
        # why not just include all of them?
        @challenges = Challenge.includes({ badges: [:badge_maps] }, :creator)
        unless logged_in_as_moderator
          @challenges = @challenges.where(soft_deleted: false)
        end
      end
    end
  end

  def show
    if @challenge.soft_deleted && !logged_in_as_moderator
      render_hidden("This challenge was hidden by moderation.")
    end

    respond_to do |format|
      format.html do
        if Date.current >= @challenge.start_date && (@challenge.end_date.blank? || Date.current < @challenge.end_date)
          @currentParticipants = Participation.where({ challenge_id: @challenge.id, active: true }).order('score DESC')
        else
          @currentParticipants = Participation.where({ challenge_id: @challenge.id }).order('score DESC, created_at ASC')
        end
        if @challenge.streak_based
          if @challenge.id == 1
            @latestEliminations = Participation.where('challenge_id = 1 AND eliminated AND end_date <= :endDate AND end_date >= :startDate', { endDate: Date.current, startDate: (Date.current - 7.days) }).order('end_date DESC')
          else
            @allEliminations = Participation.where({ challenge_id: @challenge.id, eliminated: true }).order('end_date DESC')
          end
        end
      end

      # TODO: Currently, this doesn't even require the badge or badge_maps set in `set_challenge`.
      #   Maybe that stuff should be moved into the HTML view as well?
      format.json do
        @challenge = Challenge.includes({ badges: :badge_maps }, :creator).find_by(id: params[:id])
      end
    end
  end

  def entries
    respond_to do |format|
      format.html do
        @entries = base_submissions.includes(:challenge_entries).where("challenge_entries.challenge_id = #{@challenge.id}").order('challenge_entries.created_at DESC').paginate(page: params[:page], per_page: 25)
      end

      format.json do
        @challenge = Challenge.includes(entries: :user).find_by(id: params[:id])
      end
    end
  end

  # GET /challenge/new
  def new
    @challenge = Challenge.new
    @badge_map = BadgeMap.new
    @badge = Badge.new
  end

  # POST /challenges
  # POST /challenges.json
  def create
    return unless current_user.can_make_challenges

    @challenge = Challenge.new(allowed_challenge_params)
    badge_params = allowed_badge_params
    badge_params[:nsfw_level] = allowed_challenge_params[:nsfw_level]
    @badge = Badge.new(badge_params)
    @badge.challenge_id = Challenge.maximum(:id).next

    @badge_map = BadgeMap.new(allowed_badge_map_params)

    # Temporarily set this to analyze validation
    @badge_map.challenge_id = Challenge.maximum(:id).next
    @badge_map.badge_id = Badge.maximum(:id).next

    failure = false

    respond_to do |format|
      failure = true unless @challenge.valid? && @badge.valid? && @badge_map.valid?

      # specialized checks
      if @challenge.start_date - Date.today < 7
        @challenge.errors.add(:start_date, ' should be at least a week out from today. Allow people to have sufficient advance notice to join!')
        failure = true
      end
      if @challenge.streak_based && @challenge.postfrequency == 0
        @challenge.errors.add(:streak_based, " challenges cannot have a post frequency of 'None'.")
        failure = true
      end
      if @challenge.postfrequency != 0 && @badge_map.required_score.present?
        possibleScore = ((@challenge.end_date - @challenge.start_date) / @challenge.postfrequency).to_i
        if @badge_map.required_score > possibleScore
          @badge_map.errors.add(:required_score, " is impossible to achieve within the dates and post frequency specified (only #{possibleScore} submissions possible).")
          failure = true
        end
      end

      if failure
        format.html { render :new }
      else
        @challenge.creator_id = current_user.id
        @challenge.save
        @badge.save
        @badge_map.challenge_id = @challenge.id
        @badge_map.badge_id = @badge.id
        @badge_map.save

        User.where.not(id: current_user.id).each do |u|
          # If the user has submitted within the last two weeks, send a notification of a starting challenge.
          if Submission.find_by('created_at >= ? and user_id = ?', Date.today - 14.days, u.id).nil?
            next
          end

          Notification.create(body: "#{@challenge.name} has been created by #{current_user.username}. Check it out, and consider signing up!",
                              source_type: 'Challenge',
                              source_id: @challenge.id,
                              user_id: u.id,
                              url: "/challenges/#{@challenge.id}")
        end

        format.html { redirect_to @challenge }
      end
    end
  end

  def edit; end

  def update
    failure = false

    respond_to do |format|
      newChallenge = Challenge.new(allowed_challenge_params)
      newBadgeMap = BadgeMap.new(allowed_badge_map_params)

      # specialized checks
      if Date.current < @challenge.start_date && newChallenge.start_date - Date.today < 7
        @challenge.errors.add(:start_date, ' should be at least a week out from today. Allow people to have sufficient advance notice to join!')
        failure = true
      end
      if newChallenge.streak_based && newChallenge.postfrequency == 0
        @challenge.errors.add(:streak_based, " challenges cannot have a post frequency of 'None'.")
        failure = true
      end
      if newChallenge.postfrequency != 0 && newBadgeMap.required_score.present?
        possibleScore = ((newChallenge.end_date - newChallenge.start_date) / newChallenge.postfrequency).to_i
        if newBadgeMap.required_score > possibleScore
          @badge_map.errors.add(:required_score, " is impossible to achieve within the dates and post frequency specified (only #{possibleScore} submissions possible).")
          failure = true
        end
      end

      badge_params = allowed_badge_params
      badge_params[:nsfw_level] = allowed_challenge_params[:nsfw_level] || @challenge.nsfw_level

      if !failure && @challenge.update(allowed_challenge_params) && @badge.update(badge_params) && @badge_map.update(allowed_badge_map_params)
        format.html { redirect_to @challenge }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    return unless @challenge.can_delete?

    @challenge.destroy
    respond_to do |format|
      format.html { redirect_to challenges_url }
      format.json { head :no_content }
    end
  end

  # POST
  def mod_action
    # don't let mods mess with official site content
    if @challenge.id != 1 && !@challenge.seasonal
      if params.has_key?(:reason) && params[:reason].present?
        if params.has_key? :toggle_soft_delete
          @challenge.soft_deleted = !@challenge.soft_deleted
          if @challenge.soft_deleted
            @challenge.soft_deleted_by = current_user.id
          end
          ModeratorLog.create(user_id: current_user.id,
                              target: @challenge,
                              action: "#{current_user.username} has #{@challenge.soft_deleted ? 'soft deleted' : 'reverted soft deletion on'} #{@challenge.name} by #{@creator&.username}.",
                              reason: params[:reason])
        elsif params.has_key? :change_nsfw
          @challenge.nsfw_level = params[:change_nsfw].to_i
          ModeratorLog.create(user_id: current_user.id,
                              target: @challenge,
                              action: "#{current_user.username} has changed the content level of #{@challenge.name} by #{@creator&.username} to #{nsfw_string(@challenge.nsfw_level)}.",
                              reason: params[:reason])
        end
        @challenge.save
      end
    end

    redirect_to @challenge
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_challenge
    # FIXME: All of these variables are not necessary for every view.
    @challenge = Challenge.includes(:badges).find_by(id: params[:id])
    if @challenge.nil?
      render_not_found
      return
    end

    @creator = User.find_by(id: @challenge.creator_id)
    @badge_map = BadgeMap.find_by(challenge_id: @challenge.id)
    @badge_maps = BadgeMap.where(challenge_id: @challenge.id).order(:prestige)
    @badge = Badge.find(@badge_map.badge_id)
  end

  def allowed_badge_map_params
    params.require(:badge_map).permit(:required_score, :prestige, :description)
  end

  def allowed_challenge_params
    params.require(:challenge).permit(:name, :description, :nsfw_level, :start_date, :end_date, :streak_based, :postfrequency)
  end

  def allowed_badge_params
    params.require(:badge).permit(:name, :avatar)
  end
end
