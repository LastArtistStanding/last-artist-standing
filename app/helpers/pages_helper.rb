# frozen_string_literal: true

# General page rendering helpers.
module PagesHelper
  NOT_LOGGED_IN = -2
  NO_STREAK = -1
  NEEDS_TO_SUBMIT = 0
  SUBMITTED = 1

  FREQUENCY_STRINGS_SHORT = {
    -1 => 'Custom',
    1 => 'Daily',
    2 => 'Every Other Day',
    7 => 'Weekly'
  }.freeze

  FREQUENCY_STRINGS_LONG = {
    -1 => 'Custom Frequency',
    1 => 'Posts Daily',
    2 => 'Posts Every Other Day',
    7 => 'Posts Weekly'
  }.freeze

  def date_string(date)
    return 'None' if date.nil?

    date.strftime('%B %-d, %Y')
  end

  def date_string_short(date)
    return 'None' if date.nil?

    return date.strftime('%b %-d') if date.year == Time.now.utc.year

    date.strftime('%b %-d, %Y')
  end

  def frequency_string(frequency, long)
    return long ? 'Inactive' : 'None' if frequency.nil? || frequency.zero?

    return FREQUENCY_STRINGS_LONG[frequency] || "Posts Every #{frequency} Days" if long

    FREQUENCY_STRINGS_SHORT[frequency] || "Every #{frequency} Days"
  end

  def dad_streak_status
    return [NOT_LOGGED_IN, 0] unless logged_in?

    user_id = current_user.id
    dad_participation = Participation.find_by(active: true, challenge_id: 1, user_id: user_id)
    return [NO_STREAK, 0] if dad_participation.blank?

    dad_entries = ChallengeEntry.where("challenge_id = 1 AND user_id = #{user_id} AND \
                                        created_at >= :last_date AND created_at < :next_date",
                                       { last_date: dad_participation.last_submission_date,
                                         next_date: dad_participation.next_submission_date })
    return [SUBMITTED, days_to_deadline(dad_participation)] if dad_entries.count.positive?

    [NEEDS_TO_SUBMIT, days_to_deadline(dad_participation)]
  end

  def days_to_deadline(dad_participation)
    (dad_participation.next_submission_date - Time.now.utc.to_date).to_i
  end

  def html_escape(text)
    text.gsub! '&', '%amp;'
    text.gsub! '<', '&lt;'
    text.gsub! '>', '&gt;'
    text.gsub! '\"', '&quot;'
    text.gsub! '\'', '&#39;'
    text.gsub!(/\r\n/, '<br>')
    text
  end

  def season_to_icon_class(season_challenge_name)
    return 'fa fa-leaf' if season_challenge_name.include? 'Spring'

    return 'fa fa-sun-o' if season_challenge_name.include? 'Summer'

    return 'fa fa-cloud' if season_challenge_name.include? 'Autumn'

    return 'fa fa-snowflake-o' if season_challenge_name.include? 'Winter'

    ''
  end

  def safe_username(user_id)
    user = User.find_by(id: user_id)
    return link_to(user.username, user) if user.present?
    
    return "Account Deleted"
  end
end
