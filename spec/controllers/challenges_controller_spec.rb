# frozen_string_literal: true

describe ChallengesController do
  describe 'GET :new' do
    it 'requires login' do
      get :new
      expect_requires_login
    end
  end

  describe 'GET :edit' do
    it 'requires login' do
      get :edit, params: { id: 1 }
      expect_requires_login
    end
  end

  describe 'DELETE :destroy' do
    it 'requires login' do
      delete :destroy, params: { id: 1 }
      expect_requires_login
    end
  end
end
