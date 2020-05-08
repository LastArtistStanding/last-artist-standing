describe SessionsController do

  describe "GET 'new'" do
    it "redirects HTML requests" do
      get 'new'
      response.should redirect_to "/"
    end
  end

end
