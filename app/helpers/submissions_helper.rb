# frozen_string_literal: true

# Helper functions for views that leverage submissions.
module SubmissionsHelper
  NSFW_STRINGS = {
    1 => 'Safe',
    2 => 'Questionable',
    3 => 'Explicit'
  }.freeze
  NSFW_THUMB = 'https://s3.us-east-2.amazonaws.com/do-art-daily-public/Content+Filter+Thumb.png'
  NSFW_AVATAR = 'https://s3.us-east-2.amazonaws.com/do-art-daily-public/Content+Filter+Avatar.png'

  def nsfw_string(level)
    NSFW_STRINGS[level]
  end

  def safe_submission_thumb(submission)
    unless logged_in?
      return NSFW_THUMB if submission.nsfw_level > 1

      return submission.drawing.thumb.url
    end

    return NSFW_THUMB if current_user.nsfw_level < submission.nsfw_level

    submission.drawing.thumb.url
  end

  def safe_submission_avatar(submission)
    unless logged_in?
      return NSFW_AVATAR if submission.nsfw_level > 1

      return submission.drawing.avatar.url
    end

    return NSFW_AVATAR if current_user.nsfw_level < submission.nsfw_level

    submission.drawing.avatar.url
  end

  def safe_submission_drawing(submission)
    unless logged_in?
      return NSFW_THUMB if submission.nsfw_level > 1

      return submission.drawing.url
    end

    return NSFW_THUMB if current_user.nsfw_level < submission.nsfw_level

    submission.drawing.url
  end

  def unapproved_submissions
    Submission.includes(:user).where({submissions: { approved: false, soft_deleted: false }, users: {marked_for_death: false}})
  end

  def base_submissions(only_safe = false)
    if logged_in_as_moderator && !only_safe
      # Mods can view all submissions
      Submission.all
    else
      # Normal users can view submissions from users:
      # not marked for death
      # not soft deleted
      # approved (unless they made the submission)
      Submission.includes(:user)
                .where(users: { marked_for_death: false }, submissions: { soft_deleted: false })
                .where("submissions.approved = true OR (submissions.approved = false AND users.id = #{current_user&.id.to_i})")
    end
  end

  def next_user_submission(submission)
    nsfw_level = current_user ? current_user.nsfw_level : 1
    base_submissions.where("user_id = #{submission.user.id} AND submissions.id > #{submission.id} AND submissions.nsfw_level <= #{nsfw_level}").first
  end

  def prev_user_submission(submission)
    nsfw_level = current_user ? current_user.nsfw_level : 1
    base_submissions.where("user_id = #{submission.user.id} AND submissions.id < #{submission.id} AND submissions.nsfw_level <= #{nsfw_level}").last
  end

  def next_submission(submission)
    nsfw_level = current_user ? current_user.nsfw_level : 1
    base_submissions.where('submissions.id > ? AND submissions.nsfw_level <= ?', submission.id, nsfw_level).first
  end

  def prev_submission(submission)
    nsfw_level = current_user ? current_user.nsfw_level : 1
    base_submissions.where('submissions.id < ? AND submissions.nsfw_level <= ?', submission.id, nsfw_level).last
  end

  def random_safe_submission
    base_submissions(only_safe = true).where('submissions.nsfw_level = 1 and submissions.created_at >= ?', Time.now.utc - 14.days).sample
  end
end
