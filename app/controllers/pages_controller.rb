class PagesController < ApplicationController
    
    
    def home
        @activeChallenges = Challenge.where('start_date <= ?', Date.current)
        @upcomingChallenges = Challenge.where('start_date > ?', Date.current)
    end
    
    def login
    end
end
