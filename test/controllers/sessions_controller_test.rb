require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntergrationTest
    
    test "should get new" do
        get login_path
        assert_response :success
    end
end
