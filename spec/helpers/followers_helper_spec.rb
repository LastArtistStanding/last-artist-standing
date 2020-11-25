# frozen_string_literal: true

describe FollowersHelper do
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

  describe 'follows?' do
    it 'tells you if the current user follows another user' do
      follower = Follower.create({ user: users[0], following: users[1] })
      allow(User).to receive(:find_by).and_return(users[0])
      expect(follows?(users[1])).to be_truthy
      follower.destroy
    end
  end
end
