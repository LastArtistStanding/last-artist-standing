# frozen_string_literal: true

describe ApplicationHelper do
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
      follower = Follower.create({ follower_user_id: users[0].id, followed_user_id: users[1].id })
      allow(User).to receive(:find_by).and_return(users[0])
      expect(follows?(users[1])).to be_truthy
      follower.destroy
    end
  end
end
