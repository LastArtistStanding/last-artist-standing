# frozen_string_literal: true

# Represents a user on the website.
class User < ApplicationRecord
  NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z/.freeze
  NULLABLE_NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z|\A\z/.freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze

  COMMENT_CREATION_REQUIREMENT = 3
  CHALLENGE_CREATION_REQUIREMENT = 4
  MAX_CONCURRENT_CHALLENGES = 2
  UNLIMITED_SUBMISSIONS_REQUIREMENT = 5

  mount_uploader :avatar, ImageUploader

  attr_accessor :remember_token, :reset_token

  has_many :awards
  has_many :submissions
  has_many :participations
  has_many :badges, through: :awards
  has_many :challenges, through: :participations
  has_many :comments
  has_many :moderator_logs
  has_many :moderator_logs, as: :target
  has_one :moderator_application
  has_many :house_participations, dependent: :nullify
  has_many :followers, class_name: 'Follower', foreign_key: 'following_id', dependent: :destroy
  has_many :following, class_name: 'Follower', foreign_key: 'user_id', dependent: :destroy

  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 },
                   format: { with: NO_EXCESS_WHITESPACE }, uniqueness: { case_sensitive: false }
  validates :display_name, length: { maximum: 50 }, format: { with: NULLABLE_NO_EXCESS_WHITESPACE }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 6, maximum: 30 },
                       unless: :retain_old_password?

  validates :email_pending_verification, allow_nil: true, length: { maximum: 255 },
                                         format: { with: VALID_EMAIL_REGEX }

  def initialize(*args)
    super(*args)
    @retain_old_password = false
  end

  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost: cost)
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def update_retain_password(data)
    @retain_old_password = true
    update(data)
    @retain_old_password = false
  end

  def retain_old_password?
    @retain_old_password
  end

  def reset_email_verification
    token = User.new_token

    update_retain_password(email_pending_verification: email,
                           email_verification_digest: User.digest(token),
                           email_verification_sent_at: Time.now.utc.to_s)

    token
  end

  def send_email_verification
    token = reset_email_verification
    UserMailer.email_verification(self, token).deliver_now
  end

  def verify_email
    update_retain_password(verified: true, email_verified: true)
  end

  def verified?
    verified
  end

  def email_verified?
    email_verified
  end

  def email_verification_present?
    !email_pending_verification.nil? &&
      !email_verification_digest.nil? &&
      !email_verification_sent_at.nil?
  end

  def email_verification_valid?
    email_pending_verification == email
  end

  def email_verification_too_recent_to_resend?
    !email_verification_sent_at.nil? && email_verification_sent_at >= (Time.now.utc - 5.minutes)
  end

  def email_verification_expired?
    !email_verification_present? || email_verification_sent_at < Time.now.utc.yesterday
  end

  def email_verification_correct?(code)
    BCrypt::Password.new(email_verification_digest) == code
  end

  def reset_x_site_auth_code
    token = User.new_token

    update_retain_password(x_site_auth_digest: User.digest(token))

    token
  end

  def clear_x_site_auth_code
    update_retain_password(x_site_auth_digest: nil)
  end

  def x_site_auth_code_correct?(code)
    x_site_auth_digest.present? && BCrypt::Password.new(x_site_auth_digest) == code
  end

  def username
    return display_name if display_name.present?

    name
  end

  def get_latest_ban
    SiteBan.find_by("'#{Time.now.utc}' < expiration AND user_id = #{id}")
  end

  def can_make_comments
    return [false, 'You must verify your email address before you can comment.'] unless verified?

    return [true, nil] if highest_level >= COMMENT_CREATION_REQUIREMENT

    [false, "You must have achieved DAD level #{COMMENT_CREATION_REQUIREMENT}\
     to write comments."]
  end

  def can_make_submissions
    max_submissions = submission_limit
    num_made_today = Submission.where('created_at >= ? AND created_at <= ? AND user_id = ?',
                                      Date.current.midnight,
                                      Date.current.end_of_day, id).count

    return [true, nil] if max_submissions == -1

    return [true, nil] if num_made_today < max_submissions

    [false, "You have reached your daily submission limit (currently #{max_submissions})."]
  end

  def can_make_challenges
    if highest_level < CHALLENGE_CREATION_REQUIREMENT
      return [false, "You must have achieved DAD level\
              #{CHALLENGE_CREATION_REQUIREMENT} before you can make a challenge."]
    end

    active_challenges_made = Challenge.where('end_date > ? AND creator_id = ?',
                                             Date.current,
                                             id).count
    return [true, nil] if active_challenges_made < MAX_CONCURRENT_CHALLENGES

    [false, "You have already created #{MAX_CONCURRENT_CHALLENGES} active or upcoming\
     challenges. Please wait until they are completed before you create another."]
  end

  def has_clearance?(permission_level)
    # for each group (devs, mods, admins) there is a bit in the permission_level
    # indicating whether that group has clearance.
    # a user has clearance if they are a member of any of the groups which has clearance.
    # if all bits are set, then everyone has clearance (including users not in any group);
    # if no bits are set, then no-one has clearance.
    everyone_clearance = permission_level == ~0
    admin_clearance    = permission_level.anybits?(1 << 0)
    mod_clearance      = permission_level.anybits?(1 << 1)
    dev_clearance      = permission_level.anybits?(1 << 2)

    everyone_clearance ||
      (is_developer && dev_clearance) ||
      (is_moderator && mod_clearance) ||
      (is_admin     && admin_clearance)
  end

  def submission_limit
    max_dad_level = highest_level
    return 1 if max_dad_level.zero?

    return max_dad_level if max_dad_level < UNLIMITED_SUBMISSIONS_REQUIREMENT

    -1
  end

  def profile_picture
    profile_picture = avatar.thumb.url unless avatar.nil?

    if profile_picture.blank?
      return 'https://s3.us-east-2.amazonaws.com/do-art-daily-public/Default+User+Thumb.png'
    end

    profile_picture
  end

  def approve(reason, moderator)
    ModeratorLog.create(user_id: moderator.id,
                        target: self,
                        action: "#{moderator.username} has approved #{username}.",
                        reason: reason)
    update_attribute(:approved, true)
  end

  def lift_ban(reason, moderator)
    # Do not lift bans on users marked for death.
    unless marked_for_death
      site_ban = SiteBan.find_by("'#{Time.now.utc}' < expiration AND user_id = #{id}")
      unless site_ban.nil?
        ModeratorLog.create(user_id: moderator.id,
                            target: self,
                            action: "#{moderator.username} has lifted #{username}'s ban (original expiry: #{ApplicationController.helpers.date_string_short(site_ban.expiration)}).",
                            reason: reason)
        site_ban.destroy
      end
    end
  end

  def ban_user(duration, reason, moderator)
    # Bans cannot be modified after a user has been marked for death.
    unless marked_for_death
      # Find and update an existing ban.
      site_ban = SiteBan.find_by("'#{Time.now.utc}' < expiration AND user_id = #{id}")
      if site_ban.nil?
        # Or create a new one if not found.
        SiteBan.create(user_id: id,
                       expiration: Time.now.utc.to_date + duration.to_i.days,
                       reason: reason)
        ModeratorLog.create(user_id: moderator.id,
                            target: self,
                            action: "#{moderator.username} has banned #{username} for #{duration} days.",
                            reason: reason)
      else
        site_ban.expiration = Time.now.utc.to_date + duration.days
        site_ban.reason = reason
        site_ban.save
        ModeratorLog.create(user_id: moderator.id,
                            target: self,
                            action: "#{moderator.username} has adjusted #{username}'s ban to #{duration} days.",
                            reason: reason)
      end
    end
  end

  def mark_for_death(reason, moderator)
    ban_user(99_999, reason, moderator)
    update_attribute(:marked_for_death, true)
    ModeratorLog.create(user_id: moderator.id,
                        target: self,
                        action: "#{moderator.username} has marked #{username} for death!".upcase,
                        reason: reason)
  end

  # Shows current frequency, accounting for a change that may have happened at submit-time.
  def current_dad_frequency
    return new_frequency if new_frequency.present?

    return dad_frequency if dad_frequency.present?

    nil
  end

  def invalidate_sessions
    user_sessions = UserSession.where(user_id: id)
    user_sessions.each do |us|
      us.name = name
      us.user_id = nil
      us.save
    end
  end

  def self.search(params)
    users = all # for not existing params args
    if params[:searchname]
      users = users.where('lower(name) like lower(?) OR lower(display_name) like lower(?)',
                          "%#{params[:searchname]}%", "%#{params[:searchname]}%")
    end
    users
  end
end
