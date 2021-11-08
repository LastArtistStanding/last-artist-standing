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

    it 'nullifies their discussions' do
      user = create :user
      d = create :discussion, user: user
      user.destroy
      expect(Discussion.find(d.id).user_id).to be_nil
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

    it 'nullifies challenges they created' do
      user = create :user
      create :challenge, creator: user
      user.destroy
      expect(Challenge.where(creator_id: user.id)).to be_empty
    end

    it 'nullifies any feedback they submitted' do
      user = create :user
      create :user_feedback, user: user
      user.destroy
      expect(UserFeedback.where(user_id: user.id)).to be_empty
    end
  end

  context 'when authenticating the user', skip: 'Auth is TBD' do
    it 'create a digest' do
    end

    it 'sets the password reset attributes' do
    end

    it 'sends a password reset email' do
    end

    it 'creates a new token' do
    end

    it 'checks if the password is expired' do
    end

    it 'updates the user while retaining the password' do
    end

    it 'resets te email verification' do
    end

    it 'creates verifieds their email' do
    end

    it 'checks if they are verified' do
    end

    it 'checks if email verification is present' do
    end

    it 'checks that the email verification is valid' do
    end

    it 'checks that the email verification is too recent to resend' do
    end

    it 'checks if the email verification is expired' do
    end

    it 'checks that the email verification is correct' do
    end
  end

  context 'when using x-site auth', skip: 'Cross Site Auth is TBD' do
    it 'resets x site auth code' do
    end

    it 'validates x site code' do
    end
  end

  context 'when getting user info' do
    it 'gets the user\'s display name if available' do
      user = create :user
      user.display_name = 'Phil'
      expect(user.username).to eq('Phil')
    end

    it 'gets the user\'s name if display name is not available' do
      user = create :user
      expect(user.username).to equal(user.name)
    end

    it 'gets their dad frequency if new_frequency is not available' do
      user = create :user
      user.dad_frequency = 500
      expect(user.current_dad_frequency).to equal(user.dad_frequency)
    end

    it 'gets their new frequency if available' do
      user = create :user
      user.new_frequency = 123
      expect(user.current_dad_frequency).to equal(user.new_frequency)
    end

    it 'invalidates their sessions' do
      user = create :user
      create :user_session, user: user
      user.invalidate_sessions
      expect(user.user_session.all.length).to eq(0)
    end

    it 'won\'t let the make comments if their email is not verified' do
      user = create :user
      expect(user.can_make_comments[0]).to equal(false)
    end

    it 'won\'t allow verified users to make comments if they haven\'t reached a certain level' do
      user = create :user
      user.verify_email
      expect(user.can_make_comments[0]).to equal(false)
    end

    it 'allows sufficiently leveled users to make comments' do
      user = create :user
      user.verify_email
      user.highest_level = 100
      expect(user.can_make_comments[0]).to equal(true)
    end

    it 'sets their submission limit to one if they are new' do
      user = create :user
      expect(user.submission_limit).to equal(1)
    end

    it 'sets their submission limit to their highest level if they are not new' do
      user = create :user
      user.highest_level = 2
      expect(user.submission_limit).to equal(user.highest_level)
    end

    it 'sets their submission limit to -1 if they have no limit' do
      user = create :user
      user.highest_level = 10
      expect(user.submission_limit).to equal(-1)
    end

    it 'limits the number of submissions they can make until they reach a certain level' do
      user = create :user
      user.highest_level = 1
      create :submission, user: user
      expect(user.can_make_submissions[0]).to equal(false)
    end

    it 'allows them to make submissions if they have not reached their limit' do
      user = create :user
      user.highest_level = 2
      create :submission, user: user
      expect(user.can_make_submissions[0]).to equal(true)
    end

    it 'allows them to make unlimited submissions if they reach a certain level' do
      user = create :user
      user.highest_level = 10
      create_list(:submission, 100, user: user)
      expect(user.can_make_submissions[0]).to equal(true)
    end

    it 'does not allow low-leveled users to make challenges' do
      user = create :user
      expect(user.can_make_challenges[0]).to equal(false)
    end

    it 'does allow them to make challenges if they are of a high enough level' do
      user = create :user
      user.highest_level = 40
      expect(user.can_make_challenges[0]).to equal(true)
    end

    it 'limits them to how many concurrent challenges they can have' do
      user = create :user
      create_list(:challenge, 100, creator_id: user)
      expect(user.can_make_challenges[0]).to equal(false)
    end

    it 'checks if they are a developer', skip: 'TBD' do
    end

    it 'checks if they are a mod', skip: 'TBD' do
    end

    it 'checks if they are an admin', skip: 'TBD' do
    end

    it 'gets their profile picture if they have one', skip: 'TBD' do
    end

    it 'gets the default profile picture if they don not have one', skip: 'TBD' do
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
end
