class PagesController < ApplicationController
    
    def home
        @activeChallenges = Challenge.where('start_date <= ?', Date.current).order("start_date ASC, end_date DESC")
        @upcomingChallenges = Challenge.where('start_date > ?', Date.current).order("start_date ASC, end_date DESC")
    end
    
    def login
    end
end
