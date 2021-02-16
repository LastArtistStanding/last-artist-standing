require 'rails_helper'

RSpec.describe "LeavingDads", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/leaving_dad/index"
      expect(response).to have_http_status(:success)
    end
  end

end
