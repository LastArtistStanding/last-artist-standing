class ChallengesController < ApplicationController
  before_action :set_challenge, only: [:show, :edit, :update, :destroy, :join, :entries]
  
  # GET /challenges
  # GET /challenges.json
  def index
    @activeChallenges = Challenge.where('start_date <= ? AND (end_date > ? OR end_date IS NULL)', Date.current, Date.current).order("start_date ASC, end_date DESC")
    @upcomingChallenges = Challenge.where('start_date > ?', Date.current).order("start_date DESC, end_date DESC")
    @completedChallenges = Challenge.where('end_date <= ?', Date.current).order("start_date DESC, end_date DESC")
  end
  
  # GET
  def entries
    @challengeEntries = ChallengeEntry.includes(:submission).where(:challenge_id => @challenge.id).order("created_at DESC").paginate(:page => params[:page], :per_page => 25)
  end

  # GET /challenge/1
  # GET /challenge/1.json
  def show
    # You can't join or leave a challenge after the start date.
    if Date.current < @challenge.start_date 
      if params[:join]
        Participation.find_or_create_by({ :user_id => current_user.id, :challenge_id => @challenge.id, :score => 0, :start_date => @challenge.start_date })
      end
    
      if params[:leave]
        participation = Participation.find_by({ :user_id => current_user.id, :challenge_id => @challenge.id })
        if !participation.blank?
          participation.destroy
        end
      end
    end
    
    if Date.current >= @challenge.start_date && (@challenge.end_date.blank? || Date.current < @challenge.end_date)
      @currentParticipants = Participation.where({:challenge_id => @challenge.id, :active => true}).order("score DESC")
    else
      @currentParticipants = Participation.where({:challenge_id => @challenge.id}).order("score DESC, created_at ASC")
    end
    if @challenge.streak_based
      if @challenge.id == 1
        @latestEliminations = Participation.where("challenge_id = 1 AND eliminated AND end_date <= :endDate AND end_date >= :startDate", {endDate: Date.current, startDate: (Date.current - 7.days)}).order("end_date DESC")
      else
        @allEliminations = Participation.where({:challenge_id => @challenge.id, :eliminated => true}).order("end_date DESC")
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
      if @challenge.postfrequency != 0 && !@badge_map.required_score.blank? 
        possibleScore = ((@challenge.end_date - @challenge.start_date) / @challenge.postfrequency).to_i
        if @badge_map.required_score > possibleScore
          @badge_map.errors.add(:required_score, " is impossible to achieve within the dates and post frequency specified (only #{possibleScore} submissions possible).")
          failure = true;
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
          next if Submission.find_by("created_at >= ? and user_id = ?", Date.today - 14.day, u.id).nil?
                
          Notification.create(body: "#{@challenge.name} has been created by #{current_user.username}. Check it out, and consider signing up!",
                              source_type: "Challenge",
                              source_id: @challenge.id,
                              user_id: u.id,
                              url: "/challenges/#{@challenge.id}")
        end
        
        format.html { redirect_to @challenge }
      end
    end
  end

  def edit
  end

  def update
    failure = false
    
    respond_to do |format|
      newChallenge = Challenge.new(allowed_challenge_params)
      newBadgeMap = BadgeMap.new(allowed_badge_map_params)
      
      #specialized checks
      if Date.current < @challenge.start_date && newChallenge.start_date - Date.today < 7
        @challenge.errors.add(:start_date, " should be at least a week out from today. Allow people to have sufficient advance notice to join!")
        failure = true;
      end
      if newChallenge.streak_based && newChallenge.postfrequency == 0
        @challenge.errors.add(:streak_based, " challenges cannot have a post frequency of 'None'.")
        failure = true;
      end
      if newChallenge.postfrequency != 0 && !newBadgeMap.required_score.blank? 
        possibleScore = ((newChallenge.end_date - newChallenge.start_date) / newChallenge.postfrequency).to_i
        if newBadgeMap.required_score > possibleScore
          @badge_map.errors.add(:required_score, " is impossible to achieve within the dates and post frequency specified (only #{possibleScore} submissions possible).")
          failure = true;
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
    if @challenge.creator_id == current_user.id
      Participation.where(challenge_id: @challenge.id).destroy_all
      @badge_map.destroy
      @badge.destroy
      @challenge.destroy
      respond_to do |format|
        format.html { redirect_to challenges_url }
        format.json { head :no_content }
      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_challenge
      @challenge = Challenge.find(params[:id])
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
