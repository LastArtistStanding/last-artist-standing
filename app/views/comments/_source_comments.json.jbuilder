# frozen_string_literal: true

json._links do
  # FIXME: `source.comments_path` should be defined on all varients,
  #   rather than this sketchy solution.
  json.self { json.href "#{url_for(source)}/comments" }
  json.source { json.href url_for(source) }
end

json._embedded do
  json.comments source.comments, partial: 'comments/comment', as: :comment
end
