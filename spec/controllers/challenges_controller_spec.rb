# frozen_string_literal: true

describe ChallengesController do
  before(:each) do
    @user = create(:user)
    @challenge = create(:challenge, creator_id: @user)
    @badge = create(:badge, challenge_id: @challenge)
    @badge_map = create(:badge_map, challenge: @challenge, badge: @badge)
  end

  describe 'GET :new' do
    it 'requires login' do
      get :new
      expect_unauthenticated
    end
  end

  describe 'GET :edit' do
    it 'requires login' do
      get :edit, params: { id: @challenge.id }
      expect_unauthenticated
    end
  end

  describe 'DELETE :destroy' do
    it 'requires login' do
      delete :destroy, params: { id: @challenge.id }
      expect_unauthenticated
    end
  end
end
