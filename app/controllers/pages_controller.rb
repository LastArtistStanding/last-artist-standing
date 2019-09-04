class PagesController < ApplicationController
  def home
    dad_participations = Participation.where("challenge_id = 1").order("score DESC").includes(:user)
    
    # Get eliminations
    @latest_eliminations = []
    dad_participations.where("eliminated AND end_date = ?", (Date.today - 1.day)).order("score DESC").includes(:user).each do |dp|
      dp_user = dp.user
      level_reached = BadgeMap.where("badge_id = 1, user_id = ?, required_score > ?", dp_user.id, dp.score).order("score DESC").first.prestige
      dad_part_hash = {user: dp_user, level: level_reached, score: dp.score}
      @latest_eliminations.push dad_part_hash
    end
    
    # Get level ups.
    @level_ups = []
    dad_participations.each do |dp|
      if !BadgeMap.find_by("challenge_id = 1, required_score = ?", dp.score).nil?
        dp_user = dp.user
        level_reached = BadgeMap.where("badge_id = 1, user_id = ?, required_score > ?", dp_user.id, dp.score).order("score DESC").first.prestige
        is_new_level = !Award.find_by("badge_id = 1, user_id = ?, date_received = ?", dp_user.id, Date.today).nil?
        dad_part_hash = {user: dp_user, level: level_reached, new_level: is_new_level, score: dp.score}
        @level_ups.push dad_part_hash
      end
    end
    
    # All lists to be displayed in home
    latest_awards = Award.where("date_received = ? AND badge_id <> 1", Date.today).order("prestige DESC, badge_id DESC").includes(:user).includes(:badge)
    @awards = {}
    latest_awards.each do |a|
      if @awards[a.badge_id].nil?
        badge = a.badge
        award_hash = {badge_name: badge.name, description: a.description, prestige: a.prestige, recipients: []}
        @awards[a.badge_id].push award_hash
      end
      
      @awards[a.badge_id][:recipients].push a.user
    end
    
    @current_seasonal = Challenge.where(":todays_date >= start_date AND :todays_date < end_date AND seasonal = true", {todays_date: Date.today}).first
    @seasonal_leaderboard = Participation.where("challenge_id = ?", @current_seasonal.id).order("score DESC").includes(:user)
    
    @active_challenges = Challenge.where('start_date <= ? AND (end_date > ? OR end_date IS NULL)', Date.today, Date.today).order("start_date ASC, end_date DESC")
    @upcoming_challenges = Challenge.where('start_date > ?', Date.today).order("start_date ASC, end_date DESC")
    @ending_challenges = Challenge.where('end_date = ?', Date.today)
  end
  
  def login
  end
  
  def news
    @latestPatchNote = PatchNote.last
    @latestPatchEntries = PatchEntry.where('patchnote_id = ?', @latestPatchNote.id).order("importance DESC")
  end
end
