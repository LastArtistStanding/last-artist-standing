# frozen_string_literal: true

# i cannot make this test any shorter without sacrificing code coverage
# fuck you rubocop
describe HousesController do
  houses = []
  user = []
  before do
    user = create(:user)
    user.is_moderator = true
    user.save
    allow(controller).to receive(:current_user).and_return(user)
    allow(UserSession).to receive(:create).and_return(nil)
    allow(User).to receive(:find).and_return(user)
    3.times do
      houses.push(create(:house))
    end
  end

  after do
    houses.each(&:delete)
    houses = []
  end

  describe 'GET :index' do
    it 'renders the houses page' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET :edit' do
    it 'renders the edit page if you are a moderator' do
      get :edit, params: { id: houses[0].id }
      expect(response).to render_template(:edit)
    end

    it 'does not render the edit page if you are a not moderator' do
      user.is_moderator = false
      get :edit, params: { id: houses[0].id }
      expect(response).to render_template('pages/unauthorized')
    end
  end

  describe 'POST :update' do
    it 'redirects to houses if it was a success' do
      allow(ModeratorLog).to receive(:create).and_return(true)
      patch :update, params: { id: houses[0].id,
                               house: { house_name: 'StupidHouse' },
                               reason: { reason: 'because' } }
      expect(response).to redirect_to('/houses')
    end

    it 'renders edit when there was a failure' do
      allow(ModeratorLog).to receive(:create).and_return(true)
      patch :update, params: { id: houses[0].id,
                               house: { house_name: houses[1].house_name },
                               reason: { reason: '' } }
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET :join' do
    it 'flashes success on success' do
      post :join, params: { id: houses[0].id }
      expect(flash[:success]).to be_truthy
    end

    it 'flashes error on error' do
      hp = create(:house_participation, house_id: houses[1].id, user_id: user.id)
      post :join, params: { id: houses[0].id }
      expect(flash[:error]).to be_truthy
      hp.delete
    end
  end
end
