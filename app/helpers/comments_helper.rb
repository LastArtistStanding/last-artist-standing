# frozen_string_literal: true

module CommentsHelper
  def comment_html_path(comment)
    "#{url_for(comment.source)}\##{comment.id}"
  end
end
