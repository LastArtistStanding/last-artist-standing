# frozen_string_literal: true

# The application ID to use in requests.
def application_id
  # @application.id will always be set unless :does_not_exist is set for the example,
  # in which case we specifically want to use an id that does not exist.
  @application.id || 192_139
end

def it_handles_nonexistent_application
  it 'handles a non-existent application', :does_not_exist do
    expect_not_found
  end
end

def it_requires_that_applications_are_open
  it 'requires that applications are open', :applications_closed do
    expect_unauthorized
  end
end

def it_requires_login
  it 'requires login', :no_login do
    expect_unauthenticated
  end
end

def it_requires_correct_login
  it_requires_login

  it 'requires correct login', :incorrect_login do
    expect_unauthorized
  end
end

# The show and edit routes both have identical tests, which I have factored out here.
def show_and_edit_tests(route)
  before(:each) { get route, params: { id: application_id } }

  it_handles_nonexistent_application
  it_requires_that_applications_are_open
  it_requires_correct_login

  it 'allows admin access', :admin_login do
    expect_successful_template route
  end

  it 'allows admin access even if applications are closed', :admin_login, :applications_closed do
    expect_successful_template route
  end

  it 'works' do
    expect_successful_template route
  end
end

describe ModeratorApplicationsController do
  before(:each) do |example|
    ENV['MODERATOR_APPLICATIONS'] = example.metadata[:applications_closed] ? 'closed' : 'open'

    @user = create(:user)
    setup_session(example, @user)

    @application = build(:application, user: @user)
    @application.save! unless example.metadata[:does_not_exist]
  end

  describe 'GET :index' do
    before(:each) { get :index }

    it_requires_login

    it 'redirects to :new if the user is not an admin and has not yet applied', :does_not_exist do
      expect(response).to redirect_to(new_moderator_application_path)
    end

    it 'redirects to :show if the user is not an admin but has applied' do
      expect(response).to redirect_to(moderator_application_path(@application))
    end

    it 'works', :admin_login do
      expect_successful_template :index
    end

    it 'works even if applications are closed', :admin_login, :applications_closed do
      expect_successful_template :index
    end
  end

  describe 'GET :new' do
    before(:each) { get :new }

    it_requires_login
    it_requires_that_applications_are_open

    it 'redirects if the user already applied' do
      expect(response).to redirect_to(edit_moderator_application_path(@application))
    end

    it 'works', :does_not_exist do
      expect_successful_template :new
    end
  end

  describe 'POST :create' do
    before(:each) { post :create, params: { moderator_application: @application.attributes } }

    it_requires_login
    it_requires_that_applications_are_open

    it 'redirects if the user already applied' do
      expect(response).to redirect_to(edit_moderator_application_path(@application))
    end

    it 'works', :does_not_exist do
      expect(response).to have_http_status(:see_other)
    end
  end

  describe 'GET :show' do
    show_and_edit_tests(:show)
  end

  describe 'GET :edit' do
    show_and_edit_tests(:edit)
  end

  describe 'PUT :update' do
    before(:each) do
      put :update, params: { id: application_id, moderator_application: @application.attributes }
    end

    it_handles_nonexistent_application
    it_requires_correct_login
    it_requires_that_applications_are_open

    it 'works' do
      expect(response)
        .to redirect_to(moderator_application_path(@application))
        .and have_http_status(:see_other)
    end
  end

  describe 'DELETE :destroy' do
    before(:each) { delete :destroy, params: { id: application_id } }

    it_handles_nonexistent_application
    it_requires_correct_login
    it_requires_that_applications_are_open

    expect_record_missing =
      -> { expect(ModeratorApplication.find_by(id: @application.id)).to be_nil }

    expect_admin_access_behavior = lambda do
      expect(response).to redirect_to(moderator_applications_path)
      expect_record_missing
    end

    it 'allows admin access', :admin_login do
      expect_admin_access_behavior
    end

    it 'allows admin access even if applications are closed', :admin_login, :applications_closed do
      expect_admin_access_behavior
    end

    it 'works' do
      expect(response).to redirect_to(root_path)
      expect_record_missing
    end
  end
end
