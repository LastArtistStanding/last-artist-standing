# frozen_string_literal: true

describe SubmissionsController do
  let(:user) { create(:user) }
  let(:submission) { build(:submission, user: user) }

  before do |example|
    setup_session(example, user)
    submission.save unless example.metadata[:does_not_exist]
  end

  describe 'GET :index' do
    it 'assigns all submissions as @submissions' do
      get :index
      assigns(:submissions).should eq([submission])
    end
  end

  describe 'GET :show' do
    it 'assigns the requested submission as @submission' do
      get :show, params: { id: submission.id }
      assigns(:submission).should eq(submission)
    end
  end

  describe 'GET :new' do
    it 'assigns a new submission as @submission' do
      get :new
      assigns(:submission).should be_a_new(Submission)
    end
  end

  describe 'GET :edit' do
    it 'assigns the requested submission as @submission' do
      get :edit, params: { id: submission.id }
      assigns(:submission).should eq(submission)
    end
  end

  describe 'POST :create', :does_not_exist do
    before do
      # Required by SubmissionsController when uploading submissions.
      create(:seasonal_challenge, creator_id: user.id)
    end

    describe 'with valid params' do
      it 'creates a new Submission' do
        expect do
          post :create, params: { submission: attributes_for(:submission) }
        end.to change(Submission, :count).by(1)
      end

      it 'assigns a newly created submission as @submission' do
        post :create, params: { submission: attributes_for(:submission) }
        assigns(:submission).should be_a(Submission)
        assigns(:submission).should be_persisted
      end

      it 'redirects to the created submission' do
        post :create, params: { submission: attributes_for(:submission) }
        response.should redirect_to(Submission.last)
      end

      it 'notifies followers' do

      end
    end

    describe 'with invalid params' do
      before do
        submission.nsfw_level = -1
        post :create, params: { submission: submission.attributes }
      end

      it 'assigns a newly created but unsaved submission as @submission' do
        assigns(:submission).should be_a_new(Submission)
      end

      it 're-renders the :new template' do
        response.should render_template(:new)
      end
    end
  end

  describe 'PUT :update' do
    describe 'with valid params' do
      before do
        submission.title = 'New Title'
        put :update, params: { id: submission.id, submission: submission.attributes }
      end

      it 'updates the requested submission' do
        # FIXME: This test should test something.
      end

      it 'assigns the requested submission as @submission' do
        assigns(:submission).should eq(submission)
      end

      it 'redirects to the submission' do
        response.should redirect_to(submission)
      end
    end

    describe 'with invalid params' do
      before do
        submission.nsfw_level = -1
        put :update, params: { id: submission.id, submission: submission.attributes }
      end

      it 'assigns the submission as @submission' do
        assigns(:submission).should eq(submission)
      end

      it 're-renders the :edit template' do
        response.should render_template(:edit)
      end
    end
  end

  describe 'DELETE :destroy' do
    it 'destroys the requested submission' do
      expect do
        delete :destroy, params: { id: submission.id }
      end.to change(Submission, :count).by(-1)
    end

    it 'redirects to the submissions list' do
      delete :destroy, params: { id: submission.id }
      response.should redirect_to(submissions_url)
    end
  end
end
