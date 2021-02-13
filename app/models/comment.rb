# frozen_string_literal: true

# represents a comment object
class Comment < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  belongs_to :source, polymorphic: true
  belongs_to :user

  has_many :notifications, as: :source, dependent: :destroy
  has_many :moderator_logs, as: :target

  validates :user_id, presence: true
  validates :body, length: { maximum: 2000 }, presence: true

  scope :creation_order, -> { order(created_at: :asc) }

  def link_form
    html_renderer = Redcarpet::Render::HTML.new(escape_html: true, no_images: true)
    markdown = Redcarpet::Markdown
               .new(html_renderer, no_intra_emphasis: true, underline: true, autolink: true)

    # swap out insert submission, challenge, comment quotes
    parse_comment_links(body)
    parse_challenge_links(body)
    parse_submission_links(body)
    parse_quotes(body)
    markdown.render(body)
  end

  def parse_comment_links(body)
    body.scan(/>>\d+/).each do |q|
      body.sub! q, comment_md_link(q.scan(/\d+/).first) || q.gsub('>', '\\>')
    end
  end

  def parse_challenge_links(body)
    body.scan(/>>C\d+/).each do |q|
      body.sub! q, challenge_md_link(q.scan(/\d+/).first) || q.gsub('>', '\\>')
    end
  end

  def parse_submission_links(body)
    body.scan(/>>S\d+/).each do |q|
      body.sub! q, submission_md_link(q.scan(/\d+/).first) || q.gsub('>', '\\>')
    end
  end

  def parse_quotes(body)
    body.gsub! "\r\n", "\r\n\r\n"
    body.gsub! /(?<=.)(?<=[>|\s])>/, '\\>'
    body.gsub! /^>/, '>\\>'
  end

  def challenge_md_link(q_id)
    return if !Challenge.exists?(q_id) || Challenge.find(q_id).soft_deleted

    "[\\>\\>C#{q_id}](/challenges/#{q_id})"
  end

  def submission_md_link(q_id)
    return if !Submission.exists?(q_id) ||
              !Submission.find(q_id).approved ||
              Submission.find(q_id).soft_deleted

    "[\\>\\>S#{q_id}](/submissions/#{q_id}})"
  end

  def comment_md_link(q_id)
    c = Comment.where({ id: q_id }).includes(:source).first
    return if comment_valid(c)

    "[\\>\\>#{q_id}]" \
      "(/#{c.source_type == 'Submission' ? 'submissions' : 'forums/threads'}/"\
      "#{c.source.id}##{c.id})"
  end

  def comment_valid(com)
    com.nil? ||
      com.soft_deleted ||
      (com.source_type == 'Submission' && (!com.source.approved || com.source.soft_deleted))
  end
end
