# frozen_string_literal: true

describe HousesController do

  describe 'GET :index' do
    it 'should redirect to /houses' do
      get :index
      expect(response).to render_template(:index)
    end
  end


end
