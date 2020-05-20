# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_curruser, only: %i[submissions show edit update]
  before_action :ensure_authenticated, only: %i[edit update]
  before_action -> { ensure_authorized @curruser.id }, only: %i[edit update]
  # TODO: Also handle registration being closed for the registration form, i.e. :new.
  before_action :ensure_registration_open, only: %i[new create]

  def index
    @users = User.search(params).order('current_streak DESC, id DESC')
                 .paginate(page: params[:page], per_page: 25)
  end

  def submissions
    @user_submissions = Submission.where(user_id: @curruser.id).order('created_at DESC')
                                  .paginate(page: params[:page], per_page: 25)
  end

  def show
    @awards = Award.where('user_id = ? AND badge_id <> 1', @curruser.id).order('prestige DESC')
    @submissions = Submission.where(user_id: @curruser.id).order('created_at DESC').limit(10)
  end

  def new
    @user = User.new
    respond_to do |format|
      # Kick anyone trying to directly access /login back to the home page
      format.html { redirect_to root_url }
      # Render fresh registration form using new.js.erb
      format.js
    end
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        log_in @user
        @user.send_email_verification
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

    unless @curruser.authenticate(oldpassword)
      @curruser.errors[:oldpassword][0] = 'Invalid password.'
      render 'edit'
      return
    end

    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user][:password] = oldpassword
      params[:user][:password_confirmation] = oldpassword
    end

    if @curruser.update_attributes(user_edit_params)
      flash[:success] = 'Profile updated.'
      redirect_to @curruser
    else
      render 'edit'
    end
  end

  private

  def set_curruser
    @curruser = User.find(params[:id])
  end

  def ensure_registration_open
    return unless ENV['DISABLE_REGISTRATION'] == 'TRUE'

    render 'registration_closed'
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level)
  end

  def user_edit_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level, :display_name)
  end
end
