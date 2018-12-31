class PagesController < ApplicationController
    
    def home
        @activeChallenges = Challenge.where('start_date <= ? AND (end_date > ? OR end_date IS NULL)', Date.current, Date.current).order("start_date ASC, end_date DESC")
        @upcomingChallenges = Challenge.where('start_date > ?', Date.current).order("start_date ASC, end_date DESC")
        currentSeasonalChallenge = Challenge.where(":todays_date >= start_date AND :todays_date < end_date AND seasonal = true", {todays_date: Date.current}).first.id
        
        # All lists to be displayed in home
        @latestAwards = Award.where("date_received = ? AND badge_id <> 1", Date.today).order("prestige DESC, badge_id DESC").includes(:user)
        @levelUps = Award.where("date_received = ? AND badge_id = 1", Date.today).order("prestige DESC").includes(:user)
        @latestEliminations = Participation.where("challenge_id = 1 AND eliminated AND end_date = ?", (Date.current - 1.day)).order("score DESC").includes(:user)
        @startingChallenges = @activeChallenges.where('start_date = ?', Date.current)
        @endingChallenges = Challenge.where('end_date = ?', Date.current)
        @seasonalLeaderboard = Participation.where("challenge_id = ?", currentSeasonalChallenge).order("score DESC").includes(:user)
    end
    
    def login
    end
    
    def news
        @latestPatchNote = PatchNote.last
        @latestPatchEntries = PatchEntry.where('patchnote_id = ?', @latestPatchNote.id).order("importance DESC")
    end
end
