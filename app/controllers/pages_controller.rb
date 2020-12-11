# frozen_string_literal: true

# Controls pages like home and news
class PagesController < ApplicationController
  include CommentsHelper
  include SubmissionsHelper

  before_action :ensure_moderator, only: %i[moderation]

  def home
    @active_challenges = challenge('active')
    @upcoming_challenges = challenge('upcoming')
    @seasonal_challenge = challenge('seasonal').first
    @starting_challenges = challenge('starting')
    @ending_challenges = challenge('ending')
    @activity = activity_feed
    @forum_activity = forum_activity_rows

    # All lists to be displayed in home
    @latest_awards = Award.where('date_received = ? AND badge_id <> 1', Date.today).order('prestige DESC, badge_id DESC').includes(:user)
    @level_ups = Award.where('date_received = ? AND badge_id = 1', Date.today).order('prestige DESC').includes(:user)
    @latest_eliminations = Participation.where('challenge_id = 1 AND eliminated AND end_date = ?', (Date.current - 1.day)).order('score DESC').includes(:user)
    @seasonal_leaderboard = Participation.where('challenge_id = ?', @seasonal_challenge.id).order('score DESC').includes(:user)

    if logged_in?
      @participations = Participation.includes(challenge: [:challenge_entries])
                                     .where(participations: { user_id: current_user&.id, active: true }, challenges: {seasonal: false})
                                     .where.not(challenges: { id: 1 })
    end
  end

  def login; end

  def news
    @latest_patch_note = PatchNote.last
    @latest_patch_entries = PatchEntry.where('patchnote_id = ?', @latest_patch_note.id).order('importance DESC')
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
      {
        message: message(r.anonymous ? : "Anonymous" : (r.display_name.present? ? r.display_name : r.name), r.type, r.sub_id, r.title), 
        link: link(r.id, r.type, r.sub_id)
      }
    end
  end

  # combines sql strings and filters out results based on nsfw level
  def activity_rows
    Challenge.find_by_sql(
      "SELECT * FROM (#{challenge_act} UNION #{sub_act} UNION #{comment_submission_act}) AS new_table" \
      " WHERE nsfw_level <= #{current_user&.nsfw_level || 1} ORDER BY created_at DESC LIMIT 10"
    )
  end

  def forum_activity_rows
    discussion_posts = Discussion.order("created_at DESC").limit(10)
    forum_posts = Comment.where(source_type: "Discussion").includes(:user).includes(:source).order("created_at DESC").limit(10)
    preloader = ActiveRecord::Associations::Preloader.new
    preloader.preload(forum_posts.select { |p| p.source_type == 'Discussion' }, source: [:board])

    forum_activity = discussion_posts + forum_posts
    forum_activity = forum_activity.sort_by(&:created_at).reverse!.first(10)

    return forum_activity
  end

  # returns the sql string used to get the recent challenges
  def challenge_act
    """SELECT name, NULL as display_name, id, nsfw_level, created_at, 1 as sub_id, 'challenge' as type, '' as title, false as anonymous
    FROM challenges WHERE creator_id > 0 AND soft_deleted = false"""
  end

  # returns the sql string used to get the recent submissions
  def sub_act
    """SELECT users.name as name, users.display_name as display_name, submissions.id as id, submissions.nsfw_level as nsfw_level,
    submissions.created_at as created_at, 1 as sub_id, 'submission' as type, submissions.title as title, false as anonymous
    FROM Submissions
    INNER JOIN users ON users.id = submissions.user_id
    WHERE submissions.approved = true AND submissions.soft_deleted = false"""
  end

  # returns the sql string used to get recent comments
  def comment_submission_act
    """SELECT users.name as name, users.display_name as display_name, comments.id as id, submissions.nsfw_level as nsfw_level,
    comments.created_at as created_at, comments.source_id as sub_id, 'comment' as type, submissions.title as title, comments.anonymous as anonymous
    FROM comments
    INNER JOIN users ON users.id = comments.user_id
    INNER JOIN submissions ON submissions.id = comments.source_id
    WHERE comments.source_type='Submission'"""
  end

  # creates the message part of the feed based on the type of activity
  def message(name, type, sub_id, title)
    return "Challenge '#{name}' was created." if type == 'challenge'

    return "#{name} submitted #{title.present? ? title : "Untitled"}." if type == 'submission'

    "#{name} posted a comment on #{title.present? ? title : "Untitled"}." if type == 'comment'
  end

  # creates the link part of the feed based on the type of activity
  def link(activity_id, type, sub_id)
    return challenge_path(activity_id) if type == 'challenge'

    return submission_path(activity_id) if type == 'submission'

    "/submissions/#{sub_id}##{activity_id}"
  end

  def challenge(type)
    c = base_challenge

    return c.where('start_date <= ? AND (end_date > ? OR end_date IS NULL)', today, today) if type == 'active'

    return c.where('start_date > ?', today) if type == 'upcoming'

    return c.where('start_date = ?', today) if type == 'starting'

    return c.where('end_date = ?', today) if type == 'ending'

    c.where('seasonal = true AND start_date <= ? AND end_date > ?', today, today)
  end

  def base_challenge
    Challenge.where('soft_deleted = false AND nsfw_level <= ?', current_user&.nsfw_level || 1)
             .order('start_date ASC, end_date DESC')
  end

  def today
    Time.now.utc.to_date
  end
end
