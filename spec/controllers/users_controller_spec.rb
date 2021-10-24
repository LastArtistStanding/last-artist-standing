# frozen_string_literal: true

def post_create_user
  post :create, format: :js, params: { user: {
    name: 'test user',
    email: 'test@example.com',
    password: 'PassW0rd'
  } }
end

describe UsersController do
  let(:user) { build(:user) }

  before do |example|
    user.save! unless example.metadata[:does_not_exist]
  end

  describe 'GET :index' do
    before { get :index }

    it 'successfully renders the index template' do
      expect_successful_template :index
    end
  end

  describe 'GET :submissions' do
    before { get :submissions, params: { id: user.id } }

    it 'successfully renders the submissions template' do
      expect_successful_template :submissions
    end
  end

  describe 'GET :show' do
    before { get :show, params: { id: user.id } }

    it 'successfully renders the show template' do
      expect_successful_template :show
    end
  end

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

  describe 'GET :delete' do
    before do |example|
      setup_session(example, user)
      get :delete, params: { id: user.id }
    end

    it 'renders the delete page' do
      expect_successful_template :delete
    end

    it 'requires login', :no_login do
      expect_unauthenticated
    end

    it 'requires correct login', :incorrect_login do
      expect_unauthorized
    end
  end

  describe 'DELETE :destroy' do
    before do |example|
      setup_session(example, user)
    end

    it 'destroys the user when given the right password' do
      delete :destroy, params: { id: user.id,  oldpassword: user.password }
      expect(response).to redirect_to root_url
    end

    it 'creates feedback if provided' do
      expect do
        delete :destroy, params: {
          id: user.id,
          oldpassword: user.password,
          title: 'whatever',
          body: 'this site sucks'
        }
      end.to change(UserFeedback, :count).by(1)
    end

    it 'does not create user feedback if no body was provided' do
      expect do
        delete :destroy, params: {
          id: user.id,
          oldpassword: user.password
        }
      end.not_to change(UserFeedback, :count)
    end

    it 'does not destroy the user when given the incorrect password' do
      delete :destroy, params: { id: user.id,  oldpassword: 'bad_password' }
      expect(response).to render_template :delete
    end
  end

  describe ':create' do
    it 'returns a success message' do
      post_create_user
      expect_success_flash
    end

    it 'creates a new user' do
      expect do
        post_create_user
      end.to change(User, :count).by(1)
    end

    it 'logs the user in' do
      expect(session[:user_id]).not_to be_present
      post_create_user
      expect(session[:user_id]).to be_present
    end

    it 'sends a verification email' do
      skip 'Should be implemented as an integration test'
    end
  end

  describe ':edit' do
    before do |example|
      setup_session(example, user)
      get :edit, params: { id: user.id }
    end

    it 'requires login', :no_login do
      expect_unauthenticated
    end

    it 'requires correct login', :incorrect_login do
      expect_unauthorized
    end

    it 'successfully renders the edit template' do
      expect_successful_template :edit
    end
  end

  describe ':update' do
    before do |example|
      setup_session(example, user)
    end

    it 'requires login', :no_login do
      post :update, params: { id: user.id }
      expect_unauthenticated
    end

    it 'requires correct login', :incorrect_login do
      post :update, params: { id: user.id }
      expect_unauthorized
    end

    it 'requires correct password' do
      expect do
        post :update, params: {
          id: user.id,
          oldpassword: 'wrongpassword',
          user: {
            password: 'newpassword',
            password_confirmation: 'newpassword'
          }
        }
      end.not_to change(user, :password_digest)
      expect(response).to render_template(:edit)
    end

    it 'requires password confirmation matches' do
      expect do
        post :update, params: {
          id: user.id,
          oldpassword: 'password',
          user: {
            password: 'newpassword',
            password_confirmation: 'wrongpassword'
          }
        }
      end.not_to change(user, :password_digest)
      expect(response).to render_template(:edit)
    end

    it 'works for changing passwords' do
      expect do
        post :update, params: {
          id: user.id,
          oldpassword: 'password',
          user: {
            password: 'newpassword',
            password_confirmation: 'newpassword'
          }
        }
        user.reload
      end.to change(user, :password_digest)
      expect(response).to redirect_to(user)
    end

    it 'works for changing email' do
      skip 'Should be implemented as an integration test w/ email'
    end

    it 'works for changing avatar' do
      skip 'Should be implemented as an integration test w/ carrierwave'
    end
  end

  describe ':mod_action' do
    let(:moderator) { create(:user) }

    before do |example|
      setup_session(example, moderator)
    end

    it 'requires moderator clearance' do
      post :mod_action, params: { id: user.id, reason: 'reason', approve: true }
      expect_unauthorized
    end

    it 'requires reason', :moderator_login do
      post :mod_action, params: { id: user.id, approve: true }
      expect_danger_flash
    end

    # rubocop:disable Layout::MultilineMethodCallIndentation
    it 'can approve users', :moderator_login do
      expect do
        post :mod_action, params: { id: user.id, reason: 'reason', approve: true }
        user.reload
      end
        .to change(ModeratorLog, :count).by(1)
        .and change(user, :approved).from(false).to(true)
    end

    it 'can ban users', :moderator_login do
      expect do
        post :mod_action, params: { id: user.id, reason: 'reason', ban: true }
      end
        .to change(ModeratorLog, :count).by(1)
        .and change(SiteBan, :count).by(1)
    end

    it 'can lift bans', :moderator_login do
      create(:site_ban, user_id: user.id)
      expect do
        post :mod_action, params: { id: user.id, reason: 'reason', lift_ban: true }
      end
        .to change(ModeratorLog, :count).by(1)
    end

    it 'can mark for death', :moderator_login do
      expect do
        post :mod_action, params: { id: user.id, reason: 'reason', mark_for_death: true }
        user.reload
      end
        .to change(ModeratorLog, :count)
        .and change(user, :marked_for_death).from(false).to(true)
    end
    # rubocop:enable Layout::MultilineMethodCallIndentation

    it 'cannot lift bans from user marked for death', :moderator_login do
      post :mod_action, params: { id: user.id, reason: 'reason', mark_for_death: true }
      expect do
        post :mod_action, params: { id: user.id, reason: 'reason', lift_ban: true }
      end.not_to change(SiteBan, :count)
    end
  end
end
