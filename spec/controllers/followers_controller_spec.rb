# frozen_string_literal: true

describe FollowersController do
  users = []

  before do
    (1..2).each_with_index do |_, i|
      users.push(create(:user, name: i.to_s, email: "#{i}@test.com"))
    end
  end

  after do
    users.each do |u|
      UserSession.where('user_id = ?', u.id)&.first&.destroy
      u.destroy
    end
    users = []
  end

  describe 'POST :follow' do
    it 'creates a follower entry in the DB' do
      allow(controller).to receive(:ensure_authenticated).and_return(true)
      allow(controller).to receive(:current_user).and_return(users[0])
      post :follow, params: { id: users[1].id }
      expect(response).to redirect_to user_path(users[1])
    end
  end

  describe 'POST :unfollow' do
    it 'deletes a follower entry from the db' do
      Follower.create({ user: users[0], following: users[1] })
      allow(controller).to receive(:current_user).and_return(users[0])
      post :unfollow, params: { id: users[1].id }
      expect(Follower.where({ user_id: users[0], following: users[1] })).to be_empty
    end
  end
end
