class ChallengesController < ApplicationController
  before_action :set_challenge, only: [:show, :edit, :update, :destroy]
  
  # GET /challenges
  # GET /challenges.json
  def index
    @activeChallenges = Challenge.where('start_date <= ?', Date.current)
    @upcomingChallenges = Challenge.where('start_date > ?', Date.current)
    @completedChallenges = Challenge.where('end_date <= ?', Date.current)
  end

  # GET /challenge/1
  # GET /challenge/1.json
  def show
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
    @challenge = Challenge.new(allowed_challenge_params)
    @badge = Badge.new(allowed_badge_params)
    @badge_map = BadgeMap.new(allowed_badge_map_params)
    
    # Temporarily set this to analyze validation
    @badge_map.challenge_id = Challenge.maximum(:id).next
    @badge_map.badge_id = Badge.maximum(:id).next 
    
    failure = false
    
    respond_to do |format|
      if !@challenge.valid?
        failure = true
      end
      if !@badge.valid?
        failure = true
      end
      if !@badge_map.valid?
        failure = true
      end
      
      #specialized checks
      if @challenge.start_date - Date.today < 7
        @challenge.errors.add(:start_date, " should be at least a week out from today. Allow people to have sufficient advance notice to join!")
        failure = true;
      end
      if @challenge.streak_based && @challenge.postfrequency == 0
        @challenge.errors.add(:streak_based, " challenges cannot have a post frequency of 'None'.")
        failure = true;
      end
      if @challenge.postfrequency != 0 && !@badge_map.required_score.nil? && @badge_map.required_score > ((@challenge.end_date - @challenge.start_date) / @challenge.postfrequency)
        @badge_map.errors.add(:required_score, " is impossible to achieve within the dates and post frequency specified.")
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
        
        format.html { redirect_to root_path }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @challenge.update(allowed_challenge_params) && @badge.update(allowed_badge_params) && @badge_map.update(allowed_badge_map_params)
        format.html { redirect_to root_path }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @badge_map.destroy
    @badge.destroy
    @challenge.destroy
    respond_to do |format|
      format.html { redirect_to challenges_url }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_challenge
      @challenge = Challenge.find(params[:id])
      @badge_map = BadgeMap.find_by(challenge_id: @challenge.id)
      @badge = Badge.find(@badge_map.badge_id)
    end
  
    def allowed_badge_map_params
      params.require(:badge_map).permit(:required_score, :prestige, :description)
    end
  
    def allowed_challenge_params
      params.require(:challenge).permit(:name, :description, :start_date, :end_date, :streak_based, :postfrequency)
    end
    
    def allowed_badge_params
      params.require(:badge).permit(:name, :avatar)
    end
  
end
