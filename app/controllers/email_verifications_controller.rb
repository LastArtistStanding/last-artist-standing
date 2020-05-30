# frozen_string_literal: true

# Verify that a user
class EmailVerificationsController < ApplicationController
  before_action :set_user
  before_action :set_token
  before_action :ensure_user_exists

  # Even though a user already must be logged in to request a verification email,
  # they should still be logged in to use that link to avoid leaking metadata.
  # It's just data regarding whether their email address is verified, but still.
  before_action :ensure_logged_in, only: %i[new create edit update]
  before_action -> { ensure_authorized @user.id }, only: %i[new create edit update]

  before_action :ensure_not_already_verified, only: %i[new create edit update]

  before_action :ensure_not_too_soon, only: %i[create]

  before_action :ensure_verification_present, only: %i[edit update]
  before_action :ensure_verification_correct, only: %i[edit update]
  before_action :ensure_verification_active, only: %i[edit update]

  def new; end

  def create
    @user.send_email_verification

    flash[:success] = 'An email verification link has been sent to'\
      " #{@user.email_pending_verification}."
    redirect_to root_path
  end

  def edit; end

  def update
    @user.verify_email

    flash[:success] = 'Your email address has been verified!'
    redirect_to root_path
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])
  end

  def set_token
    @token = params[:token]
  end

  def ensure_user_exists
    return unless @user.nil?

    render_not_found
  end

  def ensure_not_already_verified
    return unless @user.email_verified?

    flash[:success] = 'You already verified your email address!'
    redirect_to root_path
  end

  def ensure_verification_present
    return if @user.email_verification_present?

    # This isn't necessarily all that great of a UX for error handling,
    # but I don't think it matters much because these errors are likely to be very rare in practice.
    flash[:danger] = 'You have not requested an email verification link! Try sending a new one.'
    redirect_to edit_user_path(@user)
  end

  def ensure_verification_correct
    return if @user.email_verification_correct?(@token)

    flash[:danger] = 'That is not the correct email verification link! Try sending a new one.'
    redirect_to edit_user_path(@user)
  end

  def ensure_verification_active
    return unless @user.email_verification_expired?

    flash[:danger] = "Your email verification link has expired! You'll need to send a new one."
    redirect_to edit_user_path(@user)
  end

  def ensure_not_too_soon
    return unless @user.email_verification_too_recent_to_resend?

    flash[:danger] = 'You already sent an email confirmation too recently! '\
      'Please re-check your inbox or wait a few minutes and try again.'
    render :new, status: 400
  end
end
