# frozen_string_literal: true

# Represents a moderator application.
class ModeratorApplication < ApplicationRecord
  LENGTH_RESTRICTION = {
    maximum: 2000,
    too_long: 'This is not the place for your life story. Limit reponses to 2000 charcters.'
  }.freeze

  belongs_to :user

  # The ID of the user who is applying.
  # Users may only have one moderator application each; however, they may edit it.
  validates :user_id, presence: true, uniqueness: true

  # The user must confirm that they are at least 18 years old.
  # This data is not stored in the database, but the box must be checked on the form.
  validates :at_least_18_years_old,
            acceptance: { message: 'You must be at least 18 years old to apply to be a moderator.' }

  # The user's time zone, in Ruby's TimeZone format.
  validates :time_zone, presence: { message: 'You must specify your time zone.' }
  validates_each :time_zone do |record, attr, value|
    if ActiveSupport::TimeZone[value].nil?
      record.errors.add(attr, 'You must supply a valid time zone.')
    end
  end

  # The hours that the user would be available to actively moderate.
  validates :active_hours,
            presence: { message: 'You must specify when you can actively moderate the site.' },
            length: LENGTH_RESTRICTION

  # Why the user wants to be a moderator.
  validates :why_mod, presence: { message: 'You must explain why you should become a moderator.' },
                      length: LENGTH_RESTRICTION

  # The user's past experience as a moderator.
  validates :past_experience,
            presence: { message: 'You state whether you have any past experience as a moderator.' },
            length: LENGTH_RESTRICTION

  # How long has the user been a member of LAS/DED/DAD.
  validates :how_long,
            presence: { message: 'You must state how long you have been a member of DAD.' },
            length: LENGTH_RESTRICTION

  # What does dad mean to you?
  validates :why_dad, presence: { message: 'You must explain what DAD means to you.' },
                      length: LENGTH_RESTRICTION

  # Anything else the user would like to include in their application.
  validates :anything_else, length: LENGTH_RESTRICTION

  def time_zone_offset
    ActiveSupport::TimeZone[time_zone].formatted_offset
  end
end
