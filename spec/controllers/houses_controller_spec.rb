# frozen_string_literal: true

describe HousesController do
  describe 'GET :index' do
    it 'renders the houses page' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
