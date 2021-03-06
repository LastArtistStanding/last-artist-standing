# frozen_string_literal: true

class ModeratorApplicationsController < ApplicationController
  before_action :set_application, only: %i[show edit update destroy]
  before_action :ensure_authenticated, only: %i[index show new create edit update destroy]
  before_action -> { ensure_authorized @application.user_id }, only: %i[edit update destroy]
  before_action :ensure_authorized_or_admin, only: %i[show]
  before_action :ensure_applications_open, only: %i[show new create edit update destroy]
  before_action :prevent_conflict, only: %i[new create]

  def self.applications_deadline
    ENV['MODERATOR_APPLICATIONS_DEADLINE']
  end

  def self.applications_open?
    return false if applications_deadline.nil?

    Date.parse(applications_deadline) > Time.now.utc.to_date
  end

  def index
    # Only the administrator can see moderator applications other than their own.
    unless current_user.is_admin
      if !current_user.moderator_application.nil?
        redirect_to current_user.moderator_application
      else
        redirect_to new_moderator_application_path
      end
      return
    end

    @applications = ModeratorApplication.all.order(created_at: :desc)
  end

  def show; end

  def new
    @application = ModeratorApplication.new
  end

  def create
    @application = ModeratorApplication.new(application_params)
    @application.user_id = current_user.id

    view_result @application.save
  end

  def edit; end

  def update
    view_result @application.update(application_params)
  end

  def destroy
    @application.destroy!

    if current_user.is_admin
      redirect_to moderator_applications_path
    else
      redirect_to root_url
    end
  end

  private

  def set_application
    @application = ModeratorApplication.find_by(id: params[:id])
    return unless @application.nil?

    # If any user could see the number of moderator applications, that would leak metadata:
    # specifically, the number of users who have already applied to be moderators.
    if current_user.is_admin
      render_not_found
    else
      render_unauthorized
    end
  end

  def application_params
    params.require(:moderator_application)
          .permit(:at_least_18_years_old, :time_zone, :active_hours, :why_mod, :past_experience,
                  :how_long, :why_dad, :anything_else)
  end

  def ensure_authorized_or_admin
    # Only the administrator can view *every* moderator application.
    ensure_authorized @application.user_id unless current_user.is_admin
  end

  def ensure_applications_open
    return if ModeratorApplicationsController.applications_open? || current_user.is_admin

    render_unauthorized
  end

  # If someone has already submitted a moderator application,
  # they should edit the existing one rather than creating a new one.
  def prevent_conflict
    return if current_user.moderator_application.nil?

    redirect_to edit_moderator_application_path(current_user.moderator_application)
  end

  def view_result(successful)
    unless successful
      render :new
      return
    end

    redirect_to @application, status: :see_other
  end
end
