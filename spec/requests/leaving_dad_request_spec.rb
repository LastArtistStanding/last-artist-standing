# frozen_string_literal: true

# test for leaving dad
RSpec.describe 'LeavingDads', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/leaving_dad'
      expect(response).to have_http_status(:success)
    end
  end
end
