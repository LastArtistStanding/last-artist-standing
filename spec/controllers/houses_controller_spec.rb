# frozen_string_literal: true

describe HousesController do
  describe 'GET :index' do
    it 'renders the houses page' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'populates the user_list variable' do
      houses = HousesController.new
      allow(User).to receive(:where).and_return([{name: "1", id: 1}, {name: "2", id: 2}])
      allow(Submission).to receive(:where).and_return([{time: 0}], [{time: 120}])
      houses.index
      expect(houses.instance_variable_get(:@user_list).length).to eq(1)
      expect(houses.instance_variable_get(:@total_time)).to eq(2)
    end
  end
end
