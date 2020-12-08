# frozen_string_literal: true

class SubmissionsController < ApplicationController
  include SubmissionsHelper

  before_action :set_submission, only: %i[show edit update destroy mod_action]
  before_action :ensure_authenticated, only: %i[new create edit update destroy mod_action]
  before_action :ensure_moderator, only: %i[mod_action]
  before_action -> { ensure_authorized @submission.user_id }, only: %i[edit update destroy]
  before_action :ensure_unbanned, only: %i[new create edit update destroy]

  # GET /submissions
  # GET /submissions.json
  def index
    @date = Date.parse(params[:date] || Time.now.utc.strftime('%Y-%m-%d'))
    @submissions = bubble_followed_users(base_submissions)
                     .includes(:user)
                     .where(created_at: @date.midnight..@date.end_of_day)
                     .order('submissions.created_at DESC')
  end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
    if @submission.soft_deleted && !logged_in_as_moderator
      render_hidden("This submission was hidden by moderation.")
    end
    unless @submission.approved || (logged_in_as_moderator || @submission.user_id == current_user&.id)
      render_hidden("This submission has not been approved by moderation yet.")
    end

    @challenge_entries = ChallengeEntry.where(submission_id: @submission.id)
    @house = @submission.user.house_participations.where("join_date >=  ?", Time.now.utc.at_beginning_of_month.to_date).first&.house
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
    @participations = Participation.where({ user_id: current_user.id, active: true }).order('challenge_id ASC')
    # Inform the user of their houses score (if they are participating)
    @house_participations = current_user.house_participations.where("join_date >=  ?", Time.now.utc.at_beginning_of_month.to_date).first
    @points = @house_participations ? @house_participations.score : 0
  end

  # GET /submissions/1/edit
  def edit
    @participations = Participation.where({ user_id: current_user.id, active: true }).order('challenge_id ASC')
  end

  # POST /submissions
  # POST /submissions.json
  def create
    initial_date_time = Time.now.utc
    failure = false
    @submission = Submission.new(submission_params)
    @submission.approved = current_user.approved
    artist_id = current_user.id
    @submission.user_id = artist_id
    @participations = Participation.where({ user_id: current_user.id, active: true }).order('challenge_id ASC')

    respond_to do |format|
      if failure
        format.html { render :new }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      elsif @submission.save
        # lock in time to account for lag time
        @submission.created_at = initial_date_time
        @submission.save

        # Add points to their house when they create if it exists
        current_user.house_participations
            .where('join_date >=  ?', Time.now.utc.at_beginning_of_month.to_date)
            &.first&.add_points(submission_params[:time].to_i)

        newFrequency = params[:postfrequency].to_i
        current_user.update_attribute(:new_frequency, newFrequency)

        seasonalChallenge = Challenge.current_season

        # Add submission to DAD/Current Seasonal Challenge
        dad_ce = ChallengeEntry.create({ challenge_id: 1, submission_id: @submission.id, user_id: artist_id })
        dad_ce.created_at = initial_date_time
        dad_ce.save
        season_ce = ChallengeEntry.create({ challenge_id: seasonalChallenge.id, submission_id: @submission.id, user_id: artist_id })
        season_ce.created_at = initial_date_time
        season_ce.save

        # Last, manage all custom challenge submissions selected (to do).
        @participations = Participation.where({ user_id: artist_id, active: true }).order('challenge_id ASC')
        @participations.each do |p|
          next if params[p.challenge_id.to_s].blank?

          ce = ChallengeEntry.create({ challenge_id: p.challenge_id, submission_id: @submission.id, user_id: artist_id })
          ce.created_at = initial_date_time
          ce.save
        end

        format.html { redirect_to @submission }
        format.json { render :show, status: :created, location: @submission }
      else
        format.html { render :new }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /submissions/1
  # PATCH/PUT /submissions/1.json
  def update
    @participations = Participation.where({ user_id: current_user.id, active: true }).order('challenge_id ASC')
    curr_user_id = current_user.id

    used_params = if @submission.created_at.to_date == Time.now.utc.to_date
                   submission_params
                 else
                   limited_params
                 end

    # If the drawing itself was updated by an unapproved user, reset the approval.
    if used_params.has_key? :drawing
      @submission.approved = current_user.approved
    end

    respond_to do |format|
      old_time = @submission.time || 0
      if @submission.update(used_params)

        # Modify their points if they change their time spent on a submission
        if used_params.has_key? :time
          current_user.house_participations
              .where('join_date >=  ?', Time.now.utc.at_beginning_of_month.to_date)
              &.first
              &.update_points(
                  old_time,
                  used_params[:time].to_i,
                  @submission.created_at
              )
        end

        unless params[:postfrequency].nil?
          newFrequency = params[:postfrequency].to_i
          current_user.update_attribute(:new_frequency, newFrequency)
        end

        # This sort of information (challenge submissions) shouldn't ever change after the day it was submitted.
        if @submission.created_at.to_date == Time.now.utc.to_date
          @participations.each do |p|
            next unless p.challenge_id != 1 && !p.challenge.seasonal

            entry = ChallengeEntry.find_by({ challenge_id: p.challenge_id, submission_id: @submission.id, user_id: curr_user_id })
            # If we selected the checkbox, check if an extry exists before creating it.
            if params[p.challenge_id.to_s].present? && entry.blank?
              ChallengeEntry.create({ challenge_id: p.challenge_id, submission_id: @submission.id, user_id: curr_user_id })
            # If we unchecked the box, check if an entry doesn't exist before deleting it.
            elsif params[p.challenge_id.to_s].blank? && entry.present?
              entry.destroy
            end
          end
        end

        format.html { redirect_to @submission }
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.json
  def destroy
    # You can only delete a submission on the day you submitted it.
    return if @submission.created_at.to_date != Time.now.utc.to_date

    # Remove points for deleted submissions
    current_user.house_participations
        .where('join_date >=  ?', Time.now.utc.at_beginning_of_month.to_date)
        &.first&.remove_points(@submission.time.to_i)

    @submission.destroy
    @submission.comments.each { |comment| comment.notifications.destroy_all }

    respond_to do |format|
      format.html { redirect_to submissions_url }
      format.json { head :no_content }
    end
  end

  # POST
  def mod_action
    if params.has_key?(:reason) && params[:reason].present?
      if params.has_key? :toggle_soft_delete
        @submission.soft_deleted = !@submission.soft_deleted
        if @submission.soft_deleted
          @submission.soft_deleted_by = current_user.id
        end
        ModeratorLog.create(user_id: current_user.id,
                            target: @submission,
                            action: "#{current_user.username} has #{@submission.soft_deleted ? 'soft deleted' : 'reverted soft deletion on'} #{@submission.display_title} by #{@submission.user.username}.",
                            reason: params[:reason])
      elsif params.has_key? :toggle_approve
        @submission.approved = !@submission.approved
        ModeratorLog.create(user_id: current_user.id,
                            target: @submission,
                            action: "#{current_user.username} has #{@submission.approved ? 'approved' : 'disapproved'} #{@submission.display_title} by #{@submission.user.username}.",
                            reason: params[:reason])
      elsif params.has_key? :change_nsfw
        @submission.nsfw_level = params[:change_nsfw].to_i
        ModeratorLog.create(user_id: current_user.id,
                            target: @submission,
                            action: "#{current_user.username} has changed the content level of #{@submission.display_title} by #{@submission.user.username} to #{nsfw_string(@submission.nsfw_level)}.",
                            reason: params[:reason])
      elsif params.has_key? :change_time
        # Allow moderators to update a users time
        User.find(@submission.user_id).house_participations
            .where('join_date >=  ?', Time.now.utc.at_beginning_of_month.to_date)
            &.first&.update_points(
              @submission.time.to_i,
              params[:change_time].to_i,
              @submission.created_at
            )
        @submission.time = params[:change_time].to_i
        ModeratorLog.create do |log|
          log.user_id = current_user.id
          log.target = @submission
          log.action = "#{current_user.username} has changed the time spent of" \
                         " #{@submission.display_title} by #{@submission.user.username}" \
                         " to #{@submission.time}."
          log.reason = params[:reason]
        end
      end
      @submission.save
    end

    redirect_to @submission
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_submission
    @submission = Submission.find(params[:id])
    if logged_in_as_moderator
      @comments = Comment.where(source: @submission).includes(:user)
    else
      @comments = Comment.where(source: @submission, soft_deleted: false).includes(:user)
    end
    @comments = @comments.order(:id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def submission_params
    params.require(:submission)
          .permit(:drawing, :user_id, :nsfw_level, :title, :description, :time, :commentable, :allow_anon)
  end

  def limited_params
    params.require(:submission).permit(:nsfw_level, :title, :description, :commentable, :allow_anon)
  end
end
