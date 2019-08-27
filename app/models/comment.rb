class Comment < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  
  belongs_to :source, polymorphic: true
  belongs_to :user
  
  validates :user_id, presence: true
  validates :body, length: { maximum: 2000 }, presence: true
  
  def link_form
    return body if body.index('>>') == nil
    
    split_body = body.split('')
    
    first_gt = false
    second_gt = false
    id_link = ""
    s_index = -1
    s_indices = []
    e_indices = []
    links = []
    
    def is_valid_id(string)
      string.scan(/\D/).empty? && string[0] != '0' && !string.blank?
    end
    
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
          if is_valid_id(id_link)
            links.push id_link.to_i
            s_indices.push s_index
            e_indices.push i-1
            s_index = i
            first_gt = true
            second_gt = false
            id_link = ""
            next
          elsif id_link == ""
            s_index = i-1
            next
          else
            s_index = i
            first_gt = true
            second_gt = false
            id_link = ""
            next
          end
        elsif !!(c =~ /\d/)
          if c == '0' && id_link.blank?
            first_gt = false
            second_gt = false
            id_link = ""
            next
          end
          id_link += c
        else
          if is_valid_id(id_link)
            links.push id_link.to_i
            s_indices.push s_index
            e_indices.push i-1
            first_gt = false
            second_gt = false
            id_link = ""
            next
          else
            first_gt = false
            second_gt = false
            id_link = ""
            next
          end
        end
      else
        first_gt = false
        second_gt = false
        id_link = ""
      end
    end
    
    if is_valid_id(id_link)
      links.push id_link.to_i
      s_indices.push s_index
      e_indices.push body.length - 1
    end
    
    display_body = body
    final_comment = ""
    current_index = 0
    
    links.each_with_index do |s, i|
      link_id = s.to_i
      link_comment = Comment.find_by(id: s)
      next if link_comment.blank?
      if current_index != s_indices[i]
        final_comment = final_comment + CGI::escapeHTML(display_body[current_index..(s_indices[i] - 1)])
      end
      
      if source_type == link_comment.source_type && source_id == link_comment.source_id
        final_comment = final_comment + "<a href=\"#{"#" + link_id.to_s}\">>>#{link_id}</a>".html_safe
      else
        final_comment = final_comment + link_to(">>#{link_id}", Rails.application.routes.url_helpers.submission_path(link_comment.source_id, anchor: "#{link_id}")).html_safe
      end
      current_index = e_indices[i] + 1
    end
    
    final_comment
  end
end
