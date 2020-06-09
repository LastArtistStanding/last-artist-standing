# frozen_string_literal: true

# FIXME: Badge maps currently have a similar status to badges themselves:
#   either the model should be updated, or they should recieve their own endpoint.
#   As you can see the API currently assumes the former.
json.call(badge_map, :required_score, :prestige, :description)
