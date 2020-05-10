# frozen_string_literal: true

describe UsersController do
  describe 'GET :new' do
    it 'redirects HTML requests back to the home page' do
      get :new
      expect(response).to redirect_to root_url
    end

    it 'allows registration through the JavaScript form' do
      get :new, xhr: true
      expect(response).to render_template(:new)
    end
  end
end
