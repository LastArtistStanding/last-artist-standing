require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
    
    def setup 
        @submission = Submission.new(user_id: 1, drawing: "imglink", thumbnail: "imglink", nsfw_level: 1)
    end
    
    #VALID CASE
  
    test "should be valid" do
        assert @submission.valid?
    end
    
    #INVALID INPUTS
    #challenge_id
    
    test "user_id should be present" do
        @submission.user_id = nil
        assert_not @submission.valid?        
    end
    
    #drawing
    
    test "drawing should be present" do
        @submission.drawing = "  "
        assert_not @submission.valid?        
    end
    
    #thumbnail
    
    test "thumbnail should be present" do
        @submission.thumbnail = "  "
        assert_not @submission.valid?        
    end
    
    #nsfw_level
    
    test "nsfw_level should be present" do
        @submission.nsfw_level = nil
        assert_not @submission.valid?
    end
    
    test "nsfw_level should not be a decimal" do
        @submission.nsfw_level = 1.5
        assert_not @submission.valid?
    end
    
    test "nsfw_level should not exceed 3" do
        @submission.nsfw_level = 4
        assert_not @submission.valid?
    end
    
    test "nsfw_level should not be less than 1" do
        @submission.nsfw_level = 0
        assert_not @submission.valid?
    end
    
    #UNIQUENESS
    
    test "drawing should be unique" do 
        duplicate_submission = @submission.dup
        duplicate_submission.user_id = 2
        duplicate_submission.thumbnail = "newthumb"
        duplicate_submission.nsfw_level = 2
        @submission.save
        assert_not duplicate_submission.valid?
    end
    
end