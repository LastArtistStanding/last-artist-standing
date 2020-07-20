# frozen_string_literal: true

describe HousesController do

  class MockUser
    def initialize id
      @name = (id).to_s
      @id = id
    end

    def id
      @id
    end

    def name
      @name
    end
  end

  class MockSubmission
    def initialize time
      @time = time
    end

    def time
      @time
    end
  end

  describe 'GET :index' do
    it 'renders the houses page' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'populates the user_list variable' do
      houses = HousesController.new
      allow(User).to receive(:where).and_return([MockUser.new(1), MockUser.new(2)])
      allow(Submission).to receive(:where).and_return([MockSubmission.new(0)], [MockSubmission.new(120)])
      # User.stub(:find_each).and_yield(test_users[0]).and_yield(test_users[1])
      # Submission.stub(:where).and_yield(test_submissions)
      houses.index
      user_list = houses.instance_variable_get(:@user_list)
      total_time = houses.instance_variable_get(:@total_time)
      p user_list.length
      expect(user_list.length).to eq(1)
      expect(total_time).to eq(2)
    end
  end


end
