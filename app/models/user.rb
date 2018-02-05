class User < ActiveRecord::Base
    
    has_many :awards
    has_many :submissions
    has_many :participations
    has_many :badges, through: :awards 
    has_many :challenges, through: :participations
    
    before_save { self.email = email.downcase }
    
    NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z/
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    
    validates :name, presence: true, length: { maximum: 50 }, format: { with: NO_EXCESS_WHITESPACE }, uniqueness: {case_sensitive: false }
    validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

    has_secure_password
    validates :password, presence: true, length: { minimum: 6, maximum: 30 }
    
end


