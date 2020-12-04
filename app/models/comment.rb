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

  # HACK: What a mess!!
  #   I *think* this parses comment bodies, finds `>>`-syntax replies,
  #   and replaces them with links to the comment or submission being replied to.
  #   I'd be willing to clean this up, but until I know for sure what it does,
  #   I don't want to mess with it.
  def link_form
    return CGI.escapeHTML(body) if body.index('>>').nil?

    split_body = body.split('')

    first_gt = false
    second_gt = false
    model = ''
    id_link = ''
    s_index = -1
    s_indices = []
    e_indices = []
    links = []
    models = []

    is_valid_id = lambda { |string|
      string.scan(/\D/).empty? && string[0] != '0' && string.present?
    }

    split_body.each_with_index do |c, i|
      if !first_gt && c == '>'
        first_gt = true
        s_index = i
        next
      end
      if !second_gt && c == '>'
        second_gt = true
        next
      end
      if first_gt && second_gt
        if c == '>'
          if id_link.blank?
            s_index = i - 1
            next
          else
            links.push id_link.to_i
            s_indices.push s_index
            e_indices.push i - 1
            models.push model
            s_index = i
            first_gt = true
            second_gt = false
            id_link = ''
            model = ''
            next
          end
        elsif c == 'C' || c == 'S'
          if model.blank?
            model = c.to_sym
            next
          elsif id_link.blank?
            first_gt = false
            second_gt = false
            model = ''
            next
          else
            links.push id_link.to_i
            s_indices.push s_index
            e_indices.push i - 1
            models.push model
            first_gt = true
            second_gt = false
            id_link = ''
            model = ''
            next
          end
        elsif !!(c =~ /\d/)
          if c == '0' && id_link.blank?
            first_gt = false
            second_gt = false
            id_link = ''
            next
          elsif model.blank?
            model = :Z
          end
          id_link += c
        else
          if id_link.blank?
            first_gt = false
            second_gt = false
            model = ''
            next
          else
            links.push id_link.to_i
            s_indices.push s_index
            e_indices.push i - 1
            models.push model
            first_gt = false
            second_gt = false
            id_link = ''
            model = ''
            next
          end
        end
      else
        first_gt = false
        second_gt = false
        id_link = ''
        model = ''
      end
    end

    if is_valid_id[id_link]
      links.push id_link.to_i
      s_indices.push s_index
      e_indices.push body.length - 1
      models.push model
    end

    display_body = body
    final_comment = ''
    current_index = 0

    model_hash = { Z: Comment, C: Challenge, S: Submission }

    links.each_with_index do |s, i|
      link_id = s.to_i
      model_type = models[i]
      linked_content = model_hash[model_type].find_by(id: s)
      next if linked_content.blank?

      if current_index != s_indices[i]
        final_comment += CGI.escapeHTML(display_body[current_index..(s_indices[i] - 1)])
      end

      if model_type == :Z
        if source_type == linked_content.source_type && source_id == linked_content.source_id
          final_comment += "<a href=\"#{'#' + link_id.to_s}\">>>#{link_id}</a>".html_safe
        else
          final_comment += link_to(">>#{link_id}", Rails.application.routes.url_helpers.submission_path(linked_content.source_id, anchor: link_id.to_s)).html_safe
        end
      elsif model_type == :C
        final_comment += link_to(">>C#{link_id}", Rails.application.routes.url_helpers.challenge_path(link_id)).html_safe
      elsif model_type == :S
        final_comment += link_to(">>S#{link_id}", Rails.application.routes.url_helpers.submission_path(link_id)).html_safe
      else
        next # what the fuck?????
      end
      current_index = e_indices[i] + 1
    end

    if current_index != display_body.length
      final_comment += CGI.escapeHTML(display_body[current_index..(display_body.length - 1)])
    end

    final_comment
  end
end
