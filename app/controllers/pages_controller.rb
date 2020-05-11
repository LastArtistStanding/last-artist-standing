class PagesController < ApplicationController
    def home
      @activeChallenges = Challenge.where('start_date <= ? AND (end_date > ? OR end_date IS NULL)', Date.current, Date.current).order("start_date ASC, end_date DESC")
      @upcomingChallenges = Challenge.where('start_date > ?', Date.current).order("start_date ASC, end_date DESC")
      @currentSeasonalChallenge = Challenge.where(":todays_date >= start_date AND :todays_date < end_date AND seasonal = true", {todays_date: Date.current}).first

      # All lists to be displayed in home
      @latestAwards = Award.where("date_received = ? AND badge_id <> 1", Date.today).order("prestige DESC, badge_id DESC").includes(:user)
      @levelUps = Award.where("date_received = ? AND badge_id = 1", Date.today).order("prestige DESC").includes(:user)
      @latestEliminations = Participation.where("challenge_id = 1 AND eliminated AND end_date = ?", (Date.current - 1.day)).order("score DESC").includes(:user)
      @startingChallenges = @activeChallenges.where('start_date = ?', Date.current)
      @endingChallenges = Challenge.where('end_date = ?', Date.current)
      @seasonalLeaderboard = Participation.where("challenge_id = ?", @currentSeasonalChallenge.id).order("score DESC").includes(:user)

      @activity = []
      challenge_activity = Challenge.where('creator_id > 0').order("created_at DESC").limit(10)
      challenge_activity.each do |c|
        activity_hash = { message: "Challenge '#{c.name}' was created.", datetime: c.created_at, link: challenge_path(c.id) }
        @activity.push(activity_hash)
      end
      submission_activity = Submission.order("created_at DESC").limit(10).includes(:user)
      submission_activity.each do |s|
        activity_hash = { message: "#{s.user.username} submitted their art.", datetime: s.created_at, link: submission_path(s.id) }
        @activity.push(activity_hash)
      end
      comment_activity = Comment.order("created_at DESC").limit(10).includes(:user)
      comment_activity.each do |c|
        if c.source_type == "Submission"
          activity_hash = { message: "#{c.user.username} posted a comment on submission #{c.source_id}.", datetime: c.created_at, link: c.url }
          @activity.push(activity_hash)
        end
      end
      @activity = @activity.sort_by {|h| h[:datetime] }.reverse!
      @activity = @activity[0..9]
    end

    def login
    end

    def news
      @latestPatchNote = PatchNote.last
      @latestPatchEntries = PatchEntry.where('patchnote_id = ?', @latestPatchNote.id).order("importance DESC")
    end
end
