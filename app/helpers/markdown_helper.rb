# frozen_string_literal: true

# Helper class for parsing markdown
module MarkdownHelper

  # Main render function
  # @param body - the body of text from the submission description, challenge description or comment
  # @return - The rendered HTML
  def render_markdown(body)
    html_renderer = Redcarpet::Render::HTML.new(escape_html: true, no_images: true)
    markdown = Redcarpet::Markdown
                 .new(html_renderer, no_intra_emphasis: true, underline: true, autolink: true)

    # swap out insert submission, challenge, comment quotes
    parse_comment_links(body)
    parse_challenge_links(body)
    parse_submission_links(body)
    parse_quotes(body)
    parse_external_links(body)
    markdown.render(body)
  end

  # @function parse_comment_links
  # @abstract - Parses the body of text for a >> quote linking to a comment
  # @param body - the body of text from the submission description, challenge description or comment
  # @return - the body of text with the markdown link substituted in for the quote
  def parse_comment_links(body)
    body.scan(/>>\d+/).each do |q|
      body.sub! q, comment_md_link(q.scan(/\d+/).first) || q.gsub('>', '\\>')
    end
  end

  # @function parse_challenge_links
  # @abstract - Parses the body of text for a >> quote linking to a challenge
  # @param body - the body of text from the submission description, challenge description or comment
  # @return - the body of text with the markdown link substituted in for the quote
  def parse_challenge_links(body)
    body.scan(/>>C\d+/).each do |q|
      body.sub! q, challenge_md_link(q.scan(/\d+/).first) || q.gsub('>', '\\>')
    end
  end

  # @function parse_submission_links
  # @abstract - Parses the body of text for a >> quote linking to a submission
  # @param body - the body of text from the submission description, challenge description or comment
  # @return - the body of text with the markdown link substituted in for the quote
  def parse_submission_links(body)
    body.scan(/>>S\d+/).each do |q|
      body.sub! q, submission_md_link(q.scan(/\d+/).first) || q.gsub('>', '\\>')
    end
  end

  # @function parse_quotes
  # @abstract - Parses the body of text for block quotes. Prettifies the text with new lines.
  # @param body - the body of text from the submission description, challenge description or comment
  # @return - the body of text with the markdown link substituted in for the quote
  def parse_quotes(body)
    body.gsub! "\r\n", "\r\n\r\n"
    body.gsub!(/(?<=.)(?<=[>|\s])>/, '\\>')
    body.gsub!(/^>/, '>\\>')
  end

  # Creates a markdown link version from the quoted comment
  # @param q_id - The quote id
  def comment_md_link(q_id)
    c = Comment.where({ id: q_id }).includes(:source).first
    return if comment_invalid(c)

    "[\\>\\>#{q_id}]" \
      "(/#{c.source_type == 'Submission' ? 'submissions' : 'forums/threads'}/"\
      "#{c.source.id}##{c.id})"
  end

  # Creates a markdown link version from the quoted challenge
  # @param q_id - The quote id
  def challenge_md_link(q_id)
    return if !Challenge.exists?(q_id) || Challenge.find(q_id).soft_deleted

    "[\\>\\>C#{q_id}](/challenges/#{q_id})"
  end

  # Creates a markdown link version from the quoted submission
  # @param q_id - The quote id
  def submission_md_link(q_id)
    return if !Submission.exists?(q_id) ||
              !Submission.find(q_id).approved ||
              Submission.find(q_id).soft_deleted

    "[\\>\\>S#{q_id}](/submissions/#{q_id})"
  end

  # checks to see if a comment is exists and is not part of a deleted submission or discussion
  # @param com - the comment active record
  # @return - true or false if the comment is invalid
  def comment_invalid(com)
    com.nil? ||
      com.soft_deleted ||
      (com.source_type == 'Submission' && (!com.source.approved || com.source.soft_deleted))
  end

  # @function parse_external_links
  # @param body - the body of text from the submission description, challenge description or comment
  # @return - the body with hidden markdown links substituted
  def parse_external_links(body)
    body.scan(%r{(\[.*?\]\()(https?|ftp|mailto|news)(:\/\/[\S]+\))}).each do |q|
      next if q.join('').scan(%r{(https?|ftp|mailto|news)(:\/\/[\S]+\))}).join('')
               .starts_with?(%r{https?://#{ENV['DAD_DOMAIN']}})

      body.gsub!(q.join('').scan(%r{(https?|ftp|mailto|news)(:\/\/[\S]+\))}).join(''),
                 "/leaving_dad?external_link=#{q.join('')
                                                .scan(%r{(https?|ftp|mailto|news)(:\/\/[\S]+\))})
                                                .join('')}")
    end
  end
end
