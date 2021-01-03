# frozen_string_literal: true

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
    html_renderer = Redcarpet::Render::HTML.new(hard_wrap: true, escape_html: true)
    markdown = Redcarpet::Markdown
                 .new(html_renderer,
                      no_intra_emphasis: true,
                      strikethrough: true,
                      underline: true,
                      autolink: true,
                      superscript: true,
                      prettify: true,
                      fenced_code_blocks: true,
                      lax_spacing: true)

    # swap out insert submission, challenge, comment quotes
    body.scan(/>>[S,C]?\d+/).each do |q|
      if q.index('C').present?
        body.sub! q, challenge_md_link(q.scan(/\d+/).first) || q.gsub('>', "\\>")
      elsif q.index('S').present?
        body.sub! q, submission_md_link(q.scan(/\d+/).first) || q.gsub('>', "\\>")
      else
        body.sub! q, comment_md_link(q.scan(/\d+/).first) || q.gsub('>', "\\>")
      end
    end

    # remove any nested blockquotes (it gets ugly)
    body.gsub! /(?<=.)(?<=[>|\s])>/, "\\>"

    markdown.render(body)
  end

  def challenge_md_link(q_id)
    return if not Challenge.exists?(q_id) or Challenge.find(q_id).soft_deleted

    "[\\>\\>C#{q_id}](/challenges/#{q_id})"
  end

  def submission_md_link(q_id)
    return if not Submission.exists?(q_id) or
      not Submission.find(q_id).approved or
      Submission.find(q_id).soft_deleted

    "[\\>\\>S#{q_id}](/submissions/#{q_id}})"
  end

  def comment_md_link(q_id)
    c = Comment.where({id: q_id}).includes(:source).first
    return if c.nil? or
      c.soft_deleted or
      not c.source.approved or
      c.source.soft_deleted

    "[\\>\\>#{q_id}](/submissions/#{c.source.id}##{c.id})"
  end
end
