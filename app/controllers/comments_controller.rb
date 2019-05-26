class CommentsController < ApplicationController
include SubmissionsHelper
include UsersHelper
  
before_action :find_target

  def new
    @comment = Comment.new
  end
  
  def create
    @comment = @target.comments.new comment_params
    @comment.user_id = current_user.id
    @comment.body = @comment.body.gsub(/ +/, " ").strip
   
    can_comment, error = can_comment_on_submission(@target, current_user)
    
    if !can_comment
      flash[:error] = error
      redirect_to :back
    elsif @comment.save
      flash[:success] = "Comment posted successfully!"
      discussion_users = @target.comments.group(:user_id).pluck(:user_id)
      poster_name = current_user.username
      
      if @target.class.name == "Submission"
        discussion_users.each do |duid|
          # Lets not send notifications to ourselves.
          next if duid == current_user.id 
          # Lets not duplicate the message to the artist.
          next if @target.user_id == duid
          
          Notification.create(body: "#{poster_name} has also commented on submission #{getSubmissionTitle(@target)} (ID #{@target.id}).",
                              source_type: "Submission",
                              source_id: @target.id,
                              user_id: duid,
                              url: submission_path(@target.id))
        end
        # Send a notification to the artist if it's not ourself.
        Notification.create(body: "#{poster_name} has commented on your submission #{getSubmissionTitle(@target)} (ID #{@target.id}).",
                            source_type: "Submission",
                            source_id: @target.id,
                            user_id: @target.user_id,
                            url: submission_path(@target.id)) unless @target.user_id == current_user.id
      end
      redirect_to :back
    else
      flash[:error] = "Comment failed to post: " + @comment.errors.full_messages.join(", ")
      redirect_to :back
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    if current_user.id == @comment.user_id
      @comment.destroy
    else
      flash[:error] = "You can't delete other people's comments. Please cease these shenanigans."
    end
    redirect_to :back
  end

  private
  
  def comment_params
    params.require(:comment).permit(:body, :user_id)
  end
  
  def find_target
    @target = Submission.find_by_id(params[:submission_id]) if params[:submission_id]
  end

end
