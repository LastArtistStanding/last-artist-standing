class CommentsController < ApplicationController
include SubmissionsHelper

before_action :find_target

  def new
    @comment = Comment.new
  end

  def create
    @comment = @target.comments.new comment_params
    @comment.user_id = current_user.id
    @comment.body = @comment.body.gsub(/ +/, " ").strip

    can_comment = @target.can_be_commented_on_by(current_user)

    if !can_comment
      flash[:error] = "You do not have permission to comment on this submission."
      redirect_back(fallback_location: "/")
    elsif @comment.save
      flash[:success] = "Comment posted successfully!"
      discussion_users = @target.comments.group(:user_id).pluck(:user_id)
      poster_name = current_user.username

      if @target.class.name == "Submission"
        submission = Submission.find(@comment.source_id)
        submission.num_comments += 1
        submission.save

        discussion_users.each do |duid|
          # Lets not send notifications to ourselves.
          next if duid == current_user.id
          # Lets not duplicate the message to the artist.
          next if @target.user_id == duid

          Notification.create(body: "#{poster_name} has also commented on submission #{@target.display_title} (ID #{@target.id}).",
                              source_type: 'Comment',
                              source_id: @comment.id,
                              user_id: duid,
                              url: submission_path(@target.id))
        end
        # Send a notification to the artist if it's not ourself.
        unless @target.user_id == current_user.id
          Notification.create(
            body: "#{poster_name} has commented on your submission #{@target.display_title} (ID #{@target.id}).",
            source_type: 'Comment',
            source_id: @comment.id,
            user_id: @target.user_id,
            # FIXME: The comment URL generation logic should be its own method.
            url: submission_path(@target.id) + "\##{@comment.id}"
          )
        end
      end
      redirect_back(fallback_location: "/")
    else
      flash[:error] = "Comment failed to post: " + @comment.errors.full_messages.join(", ")
      redirect_back(fallback_location: "/")
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if current_user.id == @comment.user_id
      type = @comment.source_type
      id = @comment.source_id
      if @comment.destroy
        if type == "Submission"
          target = Submission.find(id)
        end
        target.num_comments -= 1
        target.save
      end
    else
      flash[:error] = "You can't delete other people's comments. Please cease these shenanigans."
    end
    redirect_back(fallback_location: "/")
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :user_id)
  end

  def find_target
    @target = Submission.find_by_id(params[:submission_id]) if params[:submission_id]
  end

end
