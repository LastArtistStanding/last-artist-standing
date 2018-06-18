class SubmissionsController < ApplicationController
  before_action :unauth, only: [:new, :edit, :update, :destroy]
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  # GET /submissions
  # GET /submissions.json
  def index
    @date = Date.current

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
        rescue ArgumentError
          @date = Date.current
        end
      end
      @submissions = Submission.where(created_at: @date.midnight..@date.end_of_day).order('created_at DESC')
    end
  end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
    @challenge_entries = ChallengeEntry.where(:submission_id => @submission.id)
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
    @participations = Participation.where({:user_id => current_user.id, :active => true}).order("challenge_id ASC")
  end

  # GET /submissions/1/edit
  def edit
    @participations = Participation.where({:user_id => current_user.id, :active => true}).order("challenge_id ASC")
  end

  # POST /submissions
  # POST /submissions.json
  def create
    @submission = Submission.new(submission_params)
    @submission.user_id = current_user.id
    @participations = Participation.where({:user_id => current_user.id, :active => true}).order("challenge_id ASC")
    
    respond_to do |format|
      if @submission.save
        submission_date = @submission.created_at.to_date
        nextDay = submission_date + 1.day
        newFrequency = params[:postfrequency].to_i
        current_user.update_attribute(:new_frequency, newFrequency)
        
        dadChallenge = Challenge.find(1)
        seasonalChallenge = Challenge.where(":todays_date >= start_date AND :todays_date < end_date AND seasonal = true", {todays_date: Date.current}).first
        
        # Manage DAD/Seasonal Participation
        dadPart = Participation.find_by(:user_id => current_user.id, :challenge_id => dadChallenge.id, :active => true)
        if dadPart.blank?
          dadPart = Participation.create({:user_id => current_user.id, :challenge_id => dadChallenge.id, :active => true, :eliminated => false, :score => 0, :start_date => submission_date, :last_submission_date => submission_date})
        end
        dadPart.next_submission_date = dadPart.last_submission_date + newFrequency.days
        if dadPart.next_submission_date < nextDay
          dadPart.next_submission_date = nextDay
        end
        dadPart.save
        
        seasonPart = Participation.find_by(:user_id => current_user.id, :challenge_id => seasonalChallenge.id, :active => true)
        if seasonPart.blank?
          seasonPart = Participation.create({:user_id => current_user.id, :challenge_id => seasonalChallenge.id, :active => true, :eliminated => false, :score => 0, :start_date => submission_date, :last_submission_date => submission_date, :next_submission_date => nextDay})
        end
        seasonPart.save
        
        # Add submission to DAD/Current Seasonal Challenge
        ChallengeEntry.create({:challenge_id => dadChallenge.id, :submission_id => @submission.id, :user_id => current_user.id})
        ChallengeEntry.create({:challenge_id => seasonalChallenge.id, :submission_id => @submission.id, :user_id => current_user.id})
        
        # Last, manage all custom challenge submissions selected (to do).
        @participations.each do |p|
          if !params[p.challenge_id.to_s].blank?
            ChallengeEntry.create({:challenge_id => p.challenge.id, :submission_id => @submission.id, :user_id => current_user.id})
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
    respond_to do |format|
      if @submission.update(submission_params)
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
  # def destroy
  #  @submission.destroy
  #  respond_to do |format|
  #    format.html { redirect_to submissions_url }
  #    format.json { head :no_content }
  #  end
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find(params[:id])
    end
    # Check in place to see if user is logged in. If not, redirect user to redirection page. Could also be swaped out with root_path
    def unauth
      redirect_to redirection_path unless logged_in?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def submission_params
      params.require(:submission).permit(:drawing, :user_id, :nsfw_level, :api_command)
    end
end
