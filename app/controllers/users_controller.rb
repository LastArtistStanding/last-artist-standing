# frozen_string_literal: true

class UsersController < ApplicationController
  include SubmissionsHelper

  before_action :set_user, only: %i[submissions show edit update mod_action]
  before_action :ensure_logged_in, only: %i[edit update]
  before_action -> { ensure_authorized @user.id }, only: %i[edit update]
  before_action :ensure_authenticated, only: %i[mod_action]
  before_action :ensure_moderator, only: %i[mod_action]
  before_action :ensure_verified_to_upload_avatar, only: %i[create update]
  # TODO: Also handle registration being closed for the registration form, i.e. :new.
  before_action :ensure_registration_open, only: %i[new create]

  def index
    query = User.search(params).order('current_streak DESC, id DESC')

    respond_to do |format|
      format.html do
        @users = query.paginate(page: params[:page], per_page: 25)
      end

      format.json do
        # FIXME: This is an poor way to handle pagination for an API.
        #   A new user getting created should not bump the pagination
        #   so that the API consumer skips a user.

        page = Integer(params[:page] || 1)

        @users = query.paginate(page: params[:page], per_page: 250)

        if page.nil? || page == 1
          @self_url = users_path
          @next_url = "#{users_path}?page=2"
        else
          @self_url = "#{users_path}?page=#{page}"
          @next_url = "#{users_path}?page=#{page + 1}" if @users.length.positive?
          @prev_url = "#{users_path}?page=#{page - 1}" if page > 1
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        @awards = Award.where('user_id = ? AND badge_id <> 1', @user.id).order('prestige DESC')
        @submissions = base_submissions.where(user_id: @user.id).order('submissions.created_at DESC').limit(10)
        @ban = SiteBan.find_by("'#{Time.now.utc}' < expiration AND user_id = #{@user.id}")
        @all_bans = SiteBan.where(user_id: @user.id)
      end
      format.json do
        @user = User.includes(awards: [:badge, :badge_maps, :challenge]).find(params[:id])
      end
    end
  end

  def submissions
    respond_to do |format|
      format.html do
        @user_submissions = base_submissions.where(user_id: @user.id).order('submissions.created_at DESC')
                                            .paginate(page: params[:page], per_page: 25)
      end

      format.json do
        # FIXME: Don't include soft-removed submissions.
        @user = User.includes(:submissions).find(params[:id])
      end
    end
  end

  def new
    @new_user = User.new
    respond_to do |format|
      # Kick anyone trying to directly access /login back to the home page
      format.html { redirect_to root_url }
      # Render fresh registration form using new.js.erb
      format.js
    end
  end

  def create
    @new_user = User.new(user_params)
    respond_to do |format|
      if @new_user.save
        log_in @new_user
        @new_user.send_email_verification
        flash[:success] =
          'Welcome to Do Art Daily! Please check your inbox for your email verification link.'
      end
      # Send back create.js.erb
      format.js
    end
  end

  def edit; end

  def update
    oldpassword = params[:oldpassword]

    unless @user.authenticate(oldpassword)
      @user.errors[:oldpassword][0] = 'Invalid password.'
      render 'edit'
      return
    end

    email_changed = params[:user][:email].present? && params[:user][:email] != @user.email
    if email_changed && @user.email_verification_too_recent_to_resend?
      flash[:danger] = 'You have changed your email address too recently to do that!'
      render 'edit'
      return
    end

    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user][:password] = oldpassword
      params[:user][:password_confirmation] = oldpassword
    end

    if @user.update(user_edit_params)
      # If the user has changed their email address, their email address is no longer verified.
      if email_changed
        @user.update_retain_password(email_verified: false)
        @user.send_email_verification
      end

      flash[:success] = 'Profile updated.'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def mod_action
    if params.has_key?(:reason) && params[:reason].present?
      if params.has_key?(:approve)
        @user.approve(params[:reason], current_user)
      elsif params.has_key?(:lift_ban)
        @user.lift_ban(params[:reason], current_user)
      elsif params.has_key?(:ban)
        @user.ban_user(params[:ban].to_i, params[:reason], current_user)
      elsif params.has_key?(:mark_for_death)
        @user.mark_for_death(params[:reason], current_user)
      end
    end

    redirect_to @user
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])

    render_not_found if @user.nil?
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level)
  end

  def user_edit_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level, :display_name)
  end

  def ensure_registration_open
    return unless ENV['DISABLE_REGISTRATION'] == 'TRUE'

    render 'registration_closed'
  end

  def ensure_verified_to_upload_avatar
    return unless params[:user][:avatar] && !@user.verified?

    flash[:danger] = 'You must verify your account before changing your avatar!'
    render_unverified
  end
end
