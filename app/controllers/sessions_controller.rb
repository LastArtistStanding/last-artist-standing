# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    respond_to do |format|
      # Kick anyone trying to access /login directly back to the home page
      format.html { redirect_to root_url }
      # Render a fresh login form using new.js.erb
      format.js
    end
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    respond_to do |format|
      if user&.authenticate(params[:session][:password])
        # Log the user in
        log_in user
      end
      # Render the response using create.js.erb
      format.js
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
