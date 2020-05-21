# frozen_string_literal: true

def expect_success
  expect(response).to redirect_to root_path
  expect_success_flash
end

def expect_verified
  @user.reload
  expect(@user.verified?).to be true
  expect(@user.email_verified?).to be true
end

def expect_successfully_verified
  expect_success
  expect_verified
end

def expect_unverified
  @user.reload
  expect(@user.email_verified?).to be false
  expect(@user.verified?).to be false
end

def it_requires_correct_token
  expect_failure = lambda do
    expect(response).to redirect_to(edit_user_path(@user))
    expect_danger_flash
    expect_unverified
  end

  it 'requires that the user has a token', :incorrect_token do
    expect_failure
  end

  it 'requires that the token is correct', :has_token, :incorrect_token do
    expect_failure
  end

  it 'requires that the token has not expired', :has_expired_token do
    expect_failure
  end

  it 'must not allow an already-verified user', :has_token, :verified do
    expect_successfully_verified
  end
end

describe EmailVerificationsController do
  before(:each) do |example|
    verified = example.metadata[:verified] || false
    @user = create(:user, verified: verified, email_verified: verified)
    setup_session(example, @user)
    if example.metadata[:has_token] || example.metadata[:has_expired_token]
      @token = @user.reset_email_verification
      if example.metadata[:has_expired_token]
        @user.update_retain_password(email_verification_sent_at: Time.now.utc.yesterday.to_s)
      end
    end
    @token = 'asdf' if example.metadata[:incorrect_token]
  end

  describe 'GET :new' do
    before(:each) { get :new, params: { user_id: @user.id } }

    it_requires_correct_login

    it 'must not allow an already-verified user', :verified do
      expect_successfully_verified
    end

    it 'works' do
      expect_successful_template :new
    end
  end

  describe 'POST :create' do
    before(:each) { post :create, params: { user_id: @user.id } }

    it_requires_correct_login

    it 'must not allow another email too soon', :has_token do
      expect(response).to have_http_status 400
      expect(response).to render_template :new
    end

    it 'must not allow an already-verified user', :verified do
      expect_successfully_verified
    end

    it 'works' do
      expect_success
    end
  end

  describe 'GET :edit', :no_login do
    before(:each) { get :edit, params: { user_id: @user.id, token: @token } }

    it_requires_correct_token

    it 'works', :has_token do
      expect_successful_template :edit
    end
  end

  describe 'POST :update', :no_login do
    before(:each) { post :update, params: { user_id: @user.id, token: @token } }

    it_requires_correct_token

    it 'works', :has_token do
      expect_successfully_verified
    end
  end
end
