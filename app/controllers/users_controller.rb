class UsersController < ApplicationController

  def index
    @users = User.all.order("id ASC")
  end

  def show
    @user = User.find(params[:id])
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
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    oldpassword = params[:oldpassword]
    if !!@user.authenticate(oldpassword)
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user][:password] = oldpassword
        params[:user][:password_confirmation] = oldpassword
      end
      if @user.update_attributes(user_params)
        flash[:success] = "Profile updated."
        redirect_to @user
      else
        render 'edit'
      end
    else
      @user.errors[:oldpassword][0] = "Invalid password."
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
end
