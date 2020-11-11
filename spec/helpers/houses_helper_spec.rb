# frozen_string_literal: true

require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the HousesHelper. For example:
#
# describe HousesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe HousesHelper, type: :helper do
  describe ':is_in_a_house?' do
    it 'identifies when a user is in a house' do
      user = create(:user)
      hp = create(:house_participation, user_id: user.id)
      expect(in_a_house?(hp.user_id)).to eq(true)
      hp.delete
    end

    it 'identifies when a user is not in a house' do
      expect(in_a_house?(-1)).to eq(false)
    end
  end
end
