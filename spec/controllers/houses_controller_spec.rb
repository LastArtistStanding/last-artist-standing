# frozen_string_literal: true

describe HousesController do

  test_houses = []

  before(:each) do
    (1..3).each do
      test_houses.push(create(:house))
    end
  end

  after(:each) do
    test_houses.each do |t|
      t.delete
    end
    test_houses = []
  end

  describe "GET :index" do
    it "renders the houses page" do
      get :index

      expect(response).to render_template(:index)
      expect(assigns(:date)).to eq(Time.now.utc.at_beginning_of_month.to_date)
      expect(assigns(:houses)).to eq(test_houses)
    end
  end

  describe "GET :edit" do
    it "renders the edit page if you are a moderator" do
      user = build(:user)
      user.is_moderator = true
      allow(controller).to receive(:current_user).and_return(user)

      get :edit, params: {id: test_houses[0].id}

      expect(response).to render_template(:edit)
      expect(assigns(:house)).to eq(test_houses[0])
    end

    it "does not render the edit page if you are a not moderator" do
      user = build(:user)
      user.is_moderator = false
      allow(controller).to receive(:current_user).and_return(user)

      get :edit, params: {id: test_houses[0].id}

      expect(response).to render_template("pages/unauthorized")
    end
  end

  describe "POST :update" do
    it "allows moderators to update the name" do
      user = build(:user)
      user.is_moderator = true
      allow(controller).to receive(:current_user).and_return(user)

      patch :update, params: {id: test_houses[0].id, house: {house_name: "StupidHouse"}}

      expect(response).to redirect_to("/houses")
      expect(House.find(test_houses[0].id).house_name).to eq("StupidHouse")
      expect(assigns(:house).errors).to be_empty
    end

    it "does not allow moderators to pick a duplicate name" do
      user = build(:user)
      user.is_moderator = true
      allow(controller).to receive(:current_user).and_return(user)

      control_name = test_houses[0].house_name

      patch :update, params: {id: test_houses[0].id, house: {house_name: test_houses[1].house_name}}

      expect(response).to render_template(:edit)
      expect(House.find(test_houses[0].id).house_name).to eq(control_name)
      expect(assigns(:house).errors).not_to be_empty
    end

    it "does not allow moderators to pick an empty name" do
      user = build(:user)
      user.is_moderator = true
      allow(controller).to receive(:current_user).and_return(user)

      control_name = test_houses[0].house_name

      patch :update, params: {id: test_houses[0].id, house: {house_name: ""}}

      expect(response).to render_template(:edit)
      expect(House.find(test_houses[0].id).house_name).to eq(control_name)
      expect(assigns(:house).errors).not_to be_empty
    end

    it "does not allow moderators to update old houses" do
      user = build(:user)
      user.is_moderator = true
      allow(controller).to receive(:current_user).and_return(user)

      control_name = test_houses[0].house_name


      test_houses[0].house_start = test_houses[0].house_start.prev_month
      test_houses[0].save(validate: false)

      patch :update, params: {id: test_houses[0].id, house: {house_name: "StupidHouse"}}

      expect(assigns(:house).errors).not_to be_empty
      expect(response).to render_template(:edit)
      expect(House.find(test_houses[0].id).house_name).to eq(control_name)
    end

    it "does not allow users to update the name if they are not a moderator" do
      user = build(:user)
      user.is_moderator = false
      allow(controller).to receive(:current_user).and_return(user)

      patch :update, params: {id: test_houses[0].id, house: {house_name: "StupidHouse"}}
      expect(response).to render_template("pages/unauthorized")
    end
  end

  describe "GET :join" do
    it "lets users join houses" do
      user = build(:user)
      user.id = 1

      # old houses should not have an affect
      hp_old = build(:house_participation, house_id: test_houses[1].id, user_id: user.id, join_date: test_houses[1].house_start.prev_month.to_date)
      hp_old.save(validate: false)

      allow(UserSession).to receive_message_chain(:where, :order, :limit).and_return([nil])
      allow(UserSession).to receive(:create).and_return(nil)
      allow(User).to receive(:find).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)

      get :join, params: {id: test_houses[0].id}

      expect(response).to redirect_to("/houses")

      hp = HouseParticipation.where("user_id = ? AND join_date = ?", user.id, Time.now.utc.to_date).first
      expect(hp).to be_truthy
      expect(flash[:success]).to be_truthy
      expect(flash[:error]).to be_falsey

      hp.delete
      hp_old.delete
    end

    it "does not let users join a house if you are already in a house" do
      user = build(:user)
      user.id = 1

      allow(UserSession).to receive_message_chain(:where, :order, :limit).and_return([nil])
      allow(UserSession).to receive(:create).and_return(nil)
      allow(controller).to receive(:current_user).and_return(user)

      hp = create(:house_participation, house_id: test_houses[1].id, user_id: user.id)

      get :join, params: {id: test_houses[0].id}

      expect(response).to redirect_to("/houses")
      expect(flash[:success]).to be_falsey
      expect(flash[:error]).to be_truthy

      hp.delete
    end

    it "does not let users join a house that has too many people" do
      user = build(:user)
      user.id = 1

      allow(UserSession).to receive_message_chain(:where, :order, :limit).and_return([nil])
      allow(UserSession).to receive(:create).and_return(nil)
      allow(controller).to receive(:current_user).and_return(user)

      hp = []
      (1..7).each do
        hp.push(create(:house_participation))
      end

      get :join, params: {id: test_houses[0].id}

      expect(response).to redirect_to("/houses")
      expect(flash[:success]).to be_falsey
      expect(flash[:error]).to be_truthy

      hp.each do |h|
        h.delete
      end
    end

    it "does not let users join an old house" do
      user = build(:user)
      user.id = 1

      allow(UserSession).to receive_message_chain(:where, :order, :limit).and_return([nil])
      allow(UserSession).to receive(:create).and_return(nil)
      allow(controller).to receive(:current_user).and_return(user)

      test_houses[0].house_start = "1970-01-01"
      test_houses[0].save(validate: false)
      test_houses[1].house_start = "1970-01-01"
      test_houses[1].save(validate: false)
      test_houses[2].house_start = "1970-01-01"
      test_houses[2].save(validate: false)

      get :join, params: {id: test_houses[0].id}

      expect(flash[:success]).to be_falsey
      expect(flash[:error]).to be_truthy
    end
  end
end

