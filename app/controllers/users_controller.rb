class UsersController < ApplicationController

  def index
    #@users = User.order("id DESC").paginate(:page => params[:page], :per_page => 50)
    @users = User.search(params).paginate(:page => params[:page], :per_page => 25 ).order("current_streak DESC, id DESC")
  end
  
  def submissions
    @curruser = User.find(params[:id])
    @user_submissions = Submission.where(:user_id => @curruser.id).order("created_at DESC").paginate(:page => params[:page], :per_page => 25)
  end

  def show
    @curruser = User.find(params[:id])
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
    @curruser = User.find(params[:id])
  end
  
  def update
    @curruser = User.find(params[:id])
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

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level)
    end
    
    def user_edit_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :nsfw_level, :display_name)
    end
end
