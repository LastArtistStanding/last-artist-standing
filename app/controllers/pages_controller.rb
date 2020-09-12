# frozen_string_literal: true

class PagesController < ApplicationController
  include CommentsHelper
  include SubmissionsHelper

  before_action :ensure_moderator, only: %i[moderation]

  def home
    @activeChallenges = Challenge.where('soft_deleted = false AND start_date <= ? AND (end_date > ? OR end_date IS NULL)', Date.current, Date.current).order('start_date ASC, end_date DESC')
    @upcomingChallenges = Challenge.where('soft_deleted = false AND start_date > ?', Date.current).order('start_date ASC, end_date DESC')
    @currentSeasonalChallenge = Challenge.where('soft_deleted = false AND :todays_date >= start_date AND :todays_date < end_date AND seasonal = true', { todays_date: Date.current }).first

    # All lists to be displayed in home
    @latestAwards = Award.where('date_received = ? AND badge_id <> 1', Date.today).order('prestige DESC, badge_id DESC').includes(:user)
    @levelUps = Award.where('date_received = ? AND badge_id = 1', Date.today).order('prestige DESC').includes(:user)
    @latestEliminations = Participation.where('challenge_id = 1 AND eliminated AND end_date = ?', (Date.current - 1.day)).order('score DESC').includes(:user)
    @startingChallenges = @activeChallenges.where('start_date = ?', Date.current)
    @endingChallenges = Challenge.where('end_date = ?', Date.current)
    @seasonalLeaderboard = Participation.where('challenge_id = ?', @currentSeasonalChallenge.id).order('score DESC').includes(:user)

    @activity = activity_feed

    if logged_in?
      @participations = Participation.includes(challenge: [:challenge_entries])
                                     .where(participations: { user_id: current_user.id, active: true }, challenges: {seasonal: false})
                                     .where.not(challenges: { id: 1 })
    end
  end

  def login; end

  def news
    @latestPatchNote = PatchNote.last
    @latestPatchEntries = PatchEntry.where('patchnote_id = ?', @latestPatchNote.id).order('importance DESC')
  end

  def moderation
    @admins = User.where("is_admin = true")
    @moderators = User.where("is_moderator = true")
    @moderator_logs = ModeratorLog.order('created_at DESC').limit(50)
    @unapproved_submissions = unapproved_submissions.order("submissions.created_at ASC")
    unapproved_users_objs = User.where("approved = false").includes(:participations)

    @unapproved_users = []
    unapproved_users_objs.each do |user|
      days_posted = user.participations.includes(:challenge).where({challenges: { seasonal: true }}).sum(:score)
      @unapproved_users.push({user: user, seasonal_score: days_posted}) if days_posted >= 7
    end
  end

  private

  # creates the activity has
  def activity_feed
    activity_rows.map do |r|
      {message: message(r.name, r.type, r.sub_id), link: link(r.name, r.type, r.sub_id)}
    end
  end

  # combines sql strings and filters out results based on nsfw level
  def activity_rows
    Challenge.find_by_sql(
      "SELECT * FROM (#{challenge_act} UNION #{sub_act} UNION #{comment_act}) AS new_table" \
      " WHERE nsfw_level <= #{current_user&.nsfw_level || 1} ORDER BY created_at DESC LIMIT 10"
    )
  end

  # returns the sql string used to get the recent challenges
  def challenge_act
    'SELECT name, id, nsfw_level, created_at, 1 as sub_id, \'challenge\' as type' \
    ' FROM challenges WHERE creator_id > 0 AND soft_deleted = false'
  end

  # returns the sql string used to get the recent submissions
  def sub_act
    'SELECT users.name as name, submissions.id as id, submissions.nsfw_level as nsfw_level,' \
    ' submissions.created_at as created_at, 1 as sub_id, \'submission\' as type' \
    ' FROM Submissions' \
    ' INNER JOIN users ON users.id = submissions.user_id' \
    ' WHERE submissions.approved = true AND submissions.soft_deleted = false'
  end

  # returns the sql string used to get recent comments
  def comment_act
    'SELECT users.name as name, comments.id as id, submissions.nsfw_level as nsfw_level,' \
    ' comments.created_at as created_at, comments.source_id as sub_id, \'comment\' as type' \
    ' FROM comments' \
    ' INNER JOIN users ON users.id = comments.user_id' \
    ' INNER JOIN submissions ON submissions.id = comments.source_id'
  end

  # creates the message part of the feed based on the type of activity
  def message(name, type, sub_id)
    return "Challenge '#{name}' was created" if type == 'challenge'

    return "#{name} submitted their art" if type == 'submission'

    "#{name} posted a comment on submission #{sub_id}" if type == 'comment'
  end

  # creates the link part of the feed based on the type of activity
  def link(activity_id, type, sub_id)
    return challenge_path(activity_id) if type == 'challenge'

    return submission_path(activity_id) if type == 'submission'

    "/submissions/#{sub_id}##{activity_id}"
  end
end
