require 'spec_helper'

RSpec.describe "Houses", type: :request do

  describe "GET /houses" do
    it "returns http success" do
      get "/houses"
      expect(response).to have_http_status(:success)
    end
  end

end
