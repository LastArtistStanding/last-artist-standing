# frozen_string_literal: true

# Helper functions for views that leverage participations.
module ParticipationsHelper
  PARTICIPATION_ICONS_MARKUP = {
    0 => "<i class='fa fa-times-circle' aria-hidden='true'></i>",
    1 => "<i class='fa fa-check' aria-hidden='true'></i>",
    2 => "<i class='fa fa-trophy' aria-hidden='true'></i>"
  }.freeze

  def user_is_participating(user, challenge)
    Participation.find_by(user_id: user.id, challenge_id: challenge.id).present?
  end

  def participation_icon(value)
    PARTICIPATION_ICONS_MARKUP[value]
  end
end
