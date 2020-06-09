# frozen_string_literal: true

json._links do
  json.self { json.href challenge_entries_path(@challenge) }
  json.challenge { json.href challenge_path(@challenge) }
end

json._embedded do
  # TODO: The set of possible users is fixed for this collection.
  #   We should embed the user cards as part of the collection rather than per-submission.
  json.entries @challenge.entries, partial: 'submissions/submission_preview', as: :submission
end
