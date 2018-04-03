class SubmissionsController < ApplicationController
  before_action :unauth, only: [:new, :edit, :update, :destroy]
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  # GET /submissions
  # GET /submissions.json
  def index
    @submissions = Submission.order('created_at DESC')
  end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
    @participations = Participation.where("user_id = :current_user_id AND :todays_date >= start_date AND :todays_date < end_date", {current_user_id: current_user.id, todays_date: Date.current})
  end

  # GET /submissions/1/edit
  def edit
    @participations = Participation.where("user_id = :current_user_id AND :todays_date >= start_date AND :todays_date < end_date", {current_user_id: current_user.id, todays_date: Date.current})
  end

  # POST /submissions
  # POST /submissions.json
  def create
    @submission = Submission.new(submission_params)
    @submission.user_id = current_user.id
    
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
      params.require(:submission).permit(:drawing, :user_id, :nsfw_level)
    end
end
