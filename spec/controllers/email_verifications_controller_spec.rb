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

# This is largely duplicate of `it_requires_correct_login`, only with an additional bit of metadata.
# TODO: Allow passing additional metadata for the whole block as an argument?
def it_requires_correct_login_with_token
  # The correctness of the token should be irrelevant to avoid metadata leaks.
  # However, *a* token is necessary as part of the URL/route.
  it 'requires login', :no_login, :incorrect_token do
    expect_unauthenticated
  end

  it 'requires verified login', :unverified, :incorrect_token do
    expect_unverified
  end

  it 'requires correct login', :incorrect_login, :incorrect_token do
    expect_unauthorized
  end
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

def setup_token(example)
  if example.metadata[:incorrect_token]
    @token = 'asdf'
    return
  end

  if example.metadata[:has_token] || example.metadata[:has_expired_token]
    @token = @user.reset_email_verification
  end

  if example.metadata[:has_expired_token]
    @user.update_retain_password(email_verification_sent_at: Time.now.utc.yesterday.to_s)
  end
end

describe EmailVerificationsController do
  before do |example|
    verified = example.metadata[:verified] || false
    @user = create(:user, verified: verified, email_verified: verified)
    setup_session(example, @user)
    setup_token(example)
  end

  describe 'GET :new' do
    before { get :new, params: { user_id: @user.id } }

    it_requires_correct_login

    it 'must not allow an already-verified user', :verified do
      expect_successfully_verified
    end

    it 'works' do
      expect_successful_template :new
    end
  end

  describe 'POST :create' do
    before { post :create, params: { user_id: @user.id } }

    it_requires_correct_login

    it 'must not allow another email too soon', :has_token do
      expect(response).to have_http_status :bad_request
      expect(response).to render_template :new
    end

    it 'must not allow an already-verified user', :verified do
      expect_successfully_verified
    end

    it 'works' do
      expect_success
    end
  end

  describe 'GET :edit' do
    before { get :edit, params: { user_id: @user.id, token: @token } }

    it_requires_correct_login_with_token
    it_requires_correct_token

    it 'works', :has_token do
      expect_successful_template :edit
    end
  end

  describe 'POST :update' do
    before { post :update, params: { user_id: @user.id, token: @token } }

    it_requires_correct_login_with_token
    it_requires_correct_token

    it 'works', :has_token do
      expect_successfully_verified
    end
  end
end
