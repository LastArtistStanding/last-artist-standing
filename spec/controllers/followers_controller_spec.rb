# frozen_string_literal: true

describe FollowersController do
  users = []

  before do
    (1..2).each_with_index do |_, i|
      users.push(create(:user, name: i.to_s, email: i.to_s + '@test.com'))
    end
  end

  after do
    users.each do |u|
      UserSession.where('user_id = ?', u.id)&.first&.destroy
      u.destroy
    end
    users = []
  end

  describe 'GET :follow' do
    it 'creates a follower entry in the DB' do
      allow(Follower).to receive(:create).and_return(true)
      get :follow, params: { id: 1 }
      expect(response).to redirect_to root_url
    end

    it 'does not create duplicate follows' do
      allow(Follower).to receive(:where).and_return({ empty?: false })
      get :follow, params: { id: 1 }
      expect(Follower).not_to receive(:create)
    end
  end

  describe 'GET :unfollow' do
    it 'deletes a follower entry from the db' do
      follower = Follower.create({ user: users[0], following: users[1] })
      allow(controller).to receive(:current_user).and_return(users[0])
      get :unfollow, params: { id: users[1].id }
      expect(follower).to receive(:destroy)
      follower.destroy
    end
  end
end
