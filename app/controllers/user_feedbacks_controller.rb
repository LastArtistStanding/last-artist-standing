# frozen_string_literal: true

# Controller for UserFeedback - TODO
class UserFeedbacksController < ApplicationController
  before_action :set_user_feedback, only: [:show, :edit, :update, :destroy]

  # GET /user_feedbacks
  # GET /user_feedbacks.json
  def index
    @user_feedbacks = UserFeedback.all
  end

  # GET /user_feedbacks/1
  # GET /user_feedbacks/1.json
  def show
  end

  # GET /user_feedbacks/new
  def new
    @user_feedback = UserFeedback.new
  end

  # GET /user_feedbacks/1/edit
  def edit
  end

  # POST /user_feedbacks
  # POST /user_feedbacks.json
  def create
    @user_feedback = UserFeedback.new(user_feedback_params)

    respond_to do |format|
      if @user_feedback.save
        format.html { redirect_to @user_feedback, notice: 'User feedback was successfully created.' }
        format.json { render :show, status: :created, location: @user_feedback }
      else
        format.html { render :new }
        format.json { render json: @user_feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_feedbacks/1
  # PATCH/PUT /user_feedbacks/1.json
  def update
    respond_to do |format|
      if @user_feedback.update(user_feedback_params)
        format.html { redirect_to @user_feedback, notice: 'User feedback was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_feedback }
      else
        format.html { render :edit }
        format.json { render json: @user_feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_feedbacks/1
  # DELETE /user_feedbacks/1.json
  def destroy
    @user_feedback.destroy
    respond_to do |format|
      format.html { redirect_to user_feedbacks_url, notice: 'User feedback was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_feedback
    @user_feedback = UserFeedback.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_feedback_params
    params.require(:user_feedback).permit(:title, :body)
  end
end
