# frozen_string_literal: true

class UsersController < ApplicationController
  include SubmissionsHelper

  before_action :set_curruser, only: %i[submissions show edit update mod_action]
  before_action :ensure_logged_in, only: %i[edit update]
  before_action -> { ensure_authorized @user.id }, only: %i[edit update]
  before_action :ensure_unbanned, only: %i[edit update]
  before_action :ensure_authenticated, only: %i[mod_action]
  before_action :ensure_moderator, only: %i[mod_action]
  before_action :ensure_verified_to_upload_avatar, only: %i[create update]
  # TODO: Also handle registration being closed for the registration form, i.e. :new.
  before_action :ensure_registration_open, only: %i[new create]


  def index
    @user_per_page = 25
    @users = User
      .search(params)
      .order('current_streak DESC, id DESC')
      .paginate(page: params[:page], per_page: @user_per_page)
      .includes(:house_participations)
  end

  def submissions
    @user_submissions_per_page = 25
    @user_submissions = base_submissions
      .where(user_id: @user.id)
      .order('submissions.created_at DESC')
      .paginate(page: params[:page], per_page: @user_submissions_per_page)
  end

  def show
    @awards = Award.where('user_id = ? AND badge_id <> 1', @user.id).order('prestige DESC')
    @submissions = base_submissions.where(user_id: @user.id).order('submissions.created_at DESC').limit(10)
    @ban = SiteBan.find_by("'#{Time.now.utc}' < expiration AND user_id = #{@user.id}")
    @all_bans = SiteBan.where(user_id: @user.id)
    @house = @user.house_participations.where("join_date >=  ?", Time.now.utc.at_beginning_of_month.to_date).first&.house
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

  def edit
    @followers = Follower.where(user: params[:id]).includes(:following)
  end

  def update
    oldpassword = params[:oldpassword]
    @followers = Follower.where(user: params[:id]).includes(:following)

    unless @user.authenticate(oldpassword)
      @user.errors[:oldpassword][0] = 'Invalid password.'
      rerender_user_edit
      return
    end

    email_changed = params[:user][:email].present? && params[:user][:email] != @user.email
    if email_changed && @user.email_verification_too_recent_to_resend?
      flash[:danger] = 'You have changed your email address too recently to do that!'
      rerender_user_edit
      return
    end

    user_edit_params[:bio]&.gsub! "\r", ''

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
      p user_edit_params[:bio].length
      p user_edit_params[:bio].mb_chars.length
      p @user.errors.full_messages.join(", ")
      rerender_user_edit
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

  def rerender_user_edit
    @followers = Follower.where({ user: params[:id]}).includes(:following)
    render 'edit'
  end

  def set_curruser
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level)
  end

  def user_edit_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level, :display_name, :bio)
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
