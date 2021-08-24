# frozen_string_literal: true

# represents a comment object
class Comment < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include MarkdownHelper
  belongs_to :source, polymorphic: true
  belongs_to :user

  has_many :notifications, as: :source, dependent: :destroy
  has_many :moderator_logs, as: :target

  validates :user_id, presence: true
  validates :body, length: { maximum: 2000 }, presence: true

  scope :creation_order, -> { order(created_at: :asc) }

  def link_form
    render_markdown(body)
  end
end
