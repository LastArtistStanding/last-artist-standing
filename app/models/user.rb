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
  has_one :moderator_application

  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 },
                   format: { with: NO_EXCESS_WHITESPACE }, uniqueness: { case_sensitive: false }
  validates :display_name, length: { maximum: 50 }, format: { with: NULLABLE_NO_EXCESS_WHITESPACE }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  # FIXME: Not every user update should require entering your password!
  #   Commenting it for now, but this should be re-enabled and the issue fixed before this PR is merged!
  # validates :password, presence: true, length: { minimum: 6, maximum: 30 }

  validates :email_pending_verification, allow_nil: true, length: { maximum: 255 },
                                         format: { with: VALID_EMAIL_REGEX }

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

  def send_email_verification
    token = User.new_token
    update!(email_pending_verification: email,
            email_verification_digest: User.digest(token),
            email_verification_sent_at: Time.now.utc.to_s)

    UserMailer.email_verification(self, token).deliver_now
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

  def email_verification_expired?
    !email_verification_present? || email_verification_sent_at < Time.now.utc.yesterday
  end

  def email_verification_correct?(code)
    BCrypt::Password.new(email_verification_digest) == code
  end

  def username
    return display_name unless display_name.blank?

    name
  end

  def can_make_comments
    return [true, nil] if highest_level >= COMMENT_CREATION_REQUIREMENT

    [false, "You must have achieved DAD level #{COMMENT_CREATION_REQUIREMENT}\
     to make comments on other artists' submissions."]
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

  # Shows current frequency, accounting for a change that may have happened at submit-time.
  def current_dad_frequency
    return new_frequency unless new_frequency.blank?

    return dad_frequency unless dad_frequency.blank?

    nil
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
