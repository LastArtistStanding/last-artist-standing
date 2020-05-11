class UsersController < ApplicationController
  before_action :set_curruser, only: %i[submissions show edit update]
  before_action :ensure_authenticated, only: %i[edit update]
  before_action -> { ensure_authorized @curruser.id }, only: %i[edit update]

  def index
    #@users = User.order("id DESC").paginate(:page => params[:page], :per_page => 50)
    @users = User.search(params).paginate(:page => params[:page], :per_page => 25 ).order("current_streak DESC, id DESC")
  end

  def submissions
    @user_submissions = Submission.where(:user_id => @curruser.id).order("created_at DESC").paginate(:page => params[:page], :per_page => 25)
  end

  def show
    @awards = Award.where("user_id = ? AND badge_id <> 1", @curruser.id).order("prestige DESC")
    @submissions = Submission.where({user_id: @curruser.id}).order("created_at DESC").limit(10)
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

  def edit
  end

  def update
    oldpassword = params[:oldpassword]
    if !!@curruser.authenticate(oldpassword)
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user][:password] = oldpassword
        params[:user][:password_confirmation] = oldpassword
      end
      if @curruser.update_attributes(user_edit_params)
        flash[:success] = "Profile updated."
        redirect_to @curruser
      else
        render 'edit'
      end
    else
      @curruser.errors[:oldpassword][0] = "Invalid password."
      render 'edit'
    end
  end

  def create
    if ENV['DISABLE_REGISTRATION'] != 'TRUE'
      @user = User.new(user_params)
      respond_to do |format|
        if @user.save
          log_in @user
          flash[:success] = "Welcome to Do Art Daily!"
        end
        # Send back create.js.erb
        format.js
      end
    end
  end

  private

    def set_curruser
      @curruser = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level)
    end

    def user_edit_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level, :display_name)
    end
end
