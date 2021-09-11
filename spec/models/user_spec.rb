# frozen_string_literal: true

# Test for the user model
describe User do
  context 'when deleting a user' do
    it 'deletes their submissions' do
      user = create :user
      create_list :submission, 3, user: user
      user.destroy
      expect(Submission.where(user_id: user.id)).to be_empty
    end

    it 'deletes their comments' do
      user = create :user
      create_list :comment, 3, :submission_comment, user: user
      create_list :comment, 3, :thread_comment, user: user
      create_list :comment, 3, :soft_deleted, :submission_comment, user: user
      user.destroy
      expect(Comment.where(user_id: user.id)).to be_empty
    end

    it 'nullifies the user id of moderator logs they created' do
      user = create :user
      ml = create :moderator_log, user: user
      user.destroy
      puts ModeratorLog.find(ml.id).inspect
      puts user.destroyed?
      expect(ModeratorLog.find(ml.id).user_id).to be_nil
    end

    it 'nullifies the user id of moderator logs created about them' do
      user = create :user
      ml = create :moderator_log, target: user
      user.destroy
      expect(ModeratorLog.find(ml.id).target_id).to be_nil
    end

    it 'deletes their challenge entries' do
      user = create :user
      create_list(:challenge_entry, 3, user: user)
      user.destroy
      expect(ChallengeEntry.where(user_id: user.id)).to be_empty
    end

    it 'deletes their awards' do
      user = create :user
      create_list(:award, 3, user: user)
      user.destroy
      expect(Award.where(user_id: user.id)).to be_empty
    end

    it 'deletes their participations' do
      user = create :user
      create_list(:participation, 3, user: user)
      user.destroy
      expect(Participation.where(user_id: user.id)).to be_empty
    end

    it 'deletes their notifications' do
      user = create :user
      create_list(:notification, 3, :comment, user: user)
      user.destroy
      expect(Notification.where(user_id: user.id)).to be_empty
    end

    it 'deletes records of people they followed' do
      users = create_list(:user, 2)
      create :follower, user: users[0], following: users[1]
      users[1].destroy
      expect(Follower.where(user_id: users[1].id)).to be_empty
    end

    it 'deletes records of anyone following them' do
      users = create_list(:user, 2)
      create :follower, user: users[0], following: users[1]
      users[1].destroy
      expect(Follower.where(following_id: users[1].id)).to be_empty
    end

    it 'nullifies their house participations' do
      user = create :user
      hp = create :house_participation, user: user, house: create(:house)
      user.destroy
      expect(HouseParticipation.find(hp.id).user_id).to be_nil
    end

    it 'deletes their mod application' do
      user = create :user, :mod_applicant
      user.destroy
      expect(ModeratorApplication.where(user_id: user.id)).to be_empty
    end

    it 'deletes their site ban' do
      user = create :user
      user.site_ban.create(expiration: 10.days.from_now, reason: 'test')
      user.destroy
      expect(SiteBan.where(user_id: user.id)).to be_empty
    end

    it 'aborts deletion if they are marked for death' do
      user = create :user, :marked_for_death
      user.destroy
      expect(user.destroyed?).to eq(false)
    end

    it 'nullifies their user session' do
      user = create :user
      create :user_session, user: user
      user.destroy
      expect(UserSession.where(user_id: user.id)).to be_empty
    end

    it 'nullifies their user feedback' do
      user = create :user
      create :user_feedback, user: user
      user.destroy
      expect(UserFeedback.where(user_id: user.id)).to be_empty
    end
  end

  context 'when moderating users' do
    it 'approves users' do
      user = create :user
      user.approve('because', create(:user, :moderator))
      expect(user.approved).to eq(true)
    end

    it 'gets their latest ban' do
      user = create :user
      sb = user.site_ban.create(expiration: 10.days.from_now, reason: 'test')
      expect(user.latest_ban).to eq(sb)
    end

    it 'does not lift their ban if they are marked for death' do
      user = create :user, :marked_for_death
      sb = user.site_ban.create(expiration: 10.days.from_now, reason: 'test')
      user.lift_ban('asdf', create(:user, :moderator))
      expect(user.latest_ban).to eq(sb)
    end

    it 'bans users' do
      user = create :user
      user.ban_user(10, 'reason', create(:user, :moderator))
      expect(user.latest_ban.expiration).to eq(10.days.from_now.to_date)
    end

    it 'updates bans' do
      user = create :user
      user.ban_user(10, 'reason', create(:user, :moderator))
      user.ban_user(20, 'reason', create(:user, :moderator))
      expect(user.site_ban.length).to eq(1)
    end

    it 'does not modify bans from marked_for_death users' do
      user = create :user, :marked_for_death
      user.site_ban.create(expiration: 10.days.from_now, reason: 'test')
      user.ban_user(20, 'asdf', create(:user, :moderator))
      expect(user.latest_ban.expiration).to eq(10.days.from_now.to_date)
    end

    it 'marks users for death' do
      user = create :user
      user.mark_for_death('reason', create(:user, :moderator))
      expect(user.marked_for_death).to eq(true)
    end

    it 'creates moderator logs' do
      user = create :user
      user.create_mod_log(create(:user, :moderator), 'something', 'test')

    end
  end

  context 'when checking user permissions' do
  end

  context 'when getting user info' do

  end

  context 'when authenticating the user' do

  end
end
