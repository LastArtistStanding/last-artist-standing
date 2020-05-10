describe ChallengesController do

  describe "GET 'new'" do
    it "requires login" do
      get :new
      response.should render_template(:new)
    end
  end

  describe "GET 'edit'" do
    it "requires login" do
      get :edit, params: { id: 1 }
      response.should render_template(:edit)
    end
  end

  describe "GET 'destroy'" do
    it "requires login" do
      delete :destroy, params: { id: 1 }
      response.should be_unauthorized
    end
  end

end
