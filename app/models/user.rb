class User < ActiveRecord::Base
  mount_uploader :avatar, ImageUploader

  attr_accessor :remember_token, :reset_token
  has_many :awards
  has_many :submissions
  has_many :participations
  has_many :badges, through: :awards 
  has_many :challenges, through: :participations
  has_many :comments
  
  before_save { self.email = email.downcase }
  
  NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z/
  NULLABLE_NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z|\A\z/
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  
  validates :name, presence: true, length: { maximum: 50 }, format: { with: NO_EXCESS_WHITESPACE }, uniqueness: {case_sensitive: false }
  validates :display_name, length: { maximum: 50 }, format: { with: NULLABLE_NO_EXCESS_WHITESPACE }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 6, maximum: 30 }
  
  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
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
  
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  def username
    return self.display_name unless self.display_name.blank?
    
    self.name
  end


  def self.search(params)
    users = all # for not existing params args
    users = users.where("lower(name) like lower(?) OR lower(display_name) like lower(?)", "%#{params[:searchname]}%", "%#{params[:searchname]}%") if params[:searchname]
    users
  end
end


