class SubmissionsController < ApplicationController
  before_action :unauth, only: [:edit, :update, :destroy]
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  # GET /submissions
  # GET /submissions.json
  def index
    if !params[:to].blank? || !params[:from].blank?
      if params[:to].blank?
        @submissions = Submission.where("id >= :from", {from: params[:from]}).order('id ASC')
      elsif params[:from].blank?
        @submissions = Submission.where("id <= :to", {to: params[:to]}).order('id ASC')
      else
        @submissions = Submission.where(id: params[:from]..params[:to]).order('id ASC')
      end
    else
      if !params[:date].blank?
        begin
          @date = Date.parse(params[:date])
          @date = Time.now.utc.to_date if @date > Time.now.utc.to_date
        rescue ArgumentError
          @date = Time.now.utc.to_date
        end
      else
        @date = Time.now.utc.to_date
      end
      @submissions = Submission.includes(:user).where(created_at: @date.midnight..@date.end_of_day).order('created_at DESC')
    end
  end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
    @challenge_entries = ChallengeEntry.where(submission_id: @submission.id)
  end

  # GET /submissions/new
  def new
    if logged_in?
      @submission = Submission.new
      @participations = Participation.where({user_id: current_user.id, active: true}).order("challenge_id ASC")
    end
  end

  # GET /submissions/1/edit
  def edit
    @participations = Participation.where({user_id: current_user.id, active: true}).order("challenge_id ASC")
  end

  # POST /submissions
  # POST /submissions.json
  def create
    initial_date_time = Time.now.utc
    failure = false
    @submission = Submission.new(submission_params)
    artist_id = current_user.id
    @submission.user_id = artist_id
    @participations = Participation.where({user_id: current_user.id, active: true}).order("challenge_id ASC")

    respond_to do |format|
      if failure
        format.html { render :new }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      elsif @submission.save
        #lock in time to account for lag time
        @submission.created_at = initial_date_time
        @submission.save

        newFrequency = params[:postfrequency].to_i
        current_user.update_attribute(:new_frequency, newFrequency)

        seasonalChallenge = Challenge.current_season

        # Add submission to DAD/Current Seasonal Challenge
        dad_ce = ChallengeEntry.create({challenge_id: 1, submission_id: @submission.id, user_id: artist_id})
        dad_ce.created_at = initial_date_time
        dad_ce.save
        season_ce = ChallengeEntry.create({challenge_id: seasonalChallenge.id, submission_id: @submission.id, user_id: artist_id})
        season_ce.created_at = initial_date_time
        season_ce.save

        # Last, manage all custom challenge submissions selected (to do).
        @participations = Participation.where({user_id: artist_id, active: true}).order("challenge_id ASC")
        @participations.each do |p|
          if !params[p.challenge_id.to_s].blank?
            ce = ChallengeEntry.create({challenge_id: p.challenge_id, submission_id: @submission.id, user_id: artist_id})
            ce.created_at = initial_date_time
            ce.save
          end
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
    @participations = Participation.where({user_id: current_user.id, active: true}).order("challenge_id ASC")
    curr_user_id = current_user.id

    if @submission.user_id == curr_user_id
      if @submission.created_at.to_date == Time.now.utc.to_date
        usedParams = submission_params
      else
        usedParams = limited_params
      end
      respond_to do |format|
        if @submission.update(usedParams)

          if !params[:postfrequency].nil?
            newFrequency = params[:postfrequency].to_i
            current_user.update_attribute(:new_frequency, newFrequency)
          end

          #This sort of information (challenge submissions) shouldn't ever change after the day it was submitted.
          if @submission.created_at.to_date == Time.now.utc.to_date
            @participations.each do |p|
              if p.challenge_id != 1 && !p.challenge.seasonal
                entry = ChallengeEntry.find_by({challenge_id: p.challenge_id, submission_id: @submission.id, user_id: curr_user_id})
                #If we selected the checkbox, check if an extry exists before creating it.
                if !params[p.challenge_id.to_s].blank? && entry.blank?
                  ChallengeEntry.create({challenge_id: p.challenge_id, submission_id: @submission.id, user_id: curr_user_id})
                #If we unchecked the box, check if an entry doesn't exist before deleting it.
                elsif params[p.challenge_id.to_s].blank? && !entry.blank?
                  entry.destroy
                end
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
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.json
  def destroy
    #Only the creator can delete a submission, and only on the day he submitted it.
    if @submission.user_id == current_user.id && (@submission.created_at.to_date == Date.current)
      ChallengeEntry.where(submission_id: @submission.id).destroy_all
      @submission.destroy
      respond_to do |format|
        format.html { redirect_to submissions_url }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find(params[:id])
      @comments = Comment.where(source: @submission).includes(:user)
    end
    # Check in place to see if user is logged in. If not, redirect user to redirection page. Could also be swaped out with root_path
    def unauth
      redirect_to redirection_path unless logged_in?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def submission_params
      params.require(:submission).permit(:drawing, :user_id, :nsfw_level, :title, :description, :time, :commentable)
    end

    def limited_params
      params.require(:submission).permit(:nsfw_level, :title, :description)
    end
end
