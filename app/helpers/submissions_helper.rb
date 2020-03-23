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

  def next_user_submission(submission)
    nsfw_level = current_user ? current_user.nsfw_level : 1
    submission.user.submissions.where('id > ? AND nsfw_level <= ?',
                                      submission.id,
                                      nsfw_level).first
  end

  def prev_user_submission(submission)
    nsfw_level = current_user ? current_user.nsfw_level : 1
    submission.user.submissions.where('id < ? AND nsfw_level <= ?',
                                      submission.id,
                                      nsfw_level).last
  end

  def next_submission(submission)
    nsfw_level = current_user ? current_user.nsfw_level : 1
    Submission.where('id > ? AND nsfw_level <= ?', submission.id, nsfw_level).first
  end

  def prev_submission(submission)
    nsfw_level = current_user ? current_user.nsfw_level : 1
    Submission.where('id < ? AND nsfw_level <= ?', submission.id, nsfw_level).last
  end
end
