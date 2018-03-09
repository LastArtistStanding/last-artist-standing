require 'test_helper'
require 'date'

class ChallengeTest < ActiveSupport::TestCase
  
    def setup 
        @challenge = Challenge.new(name: "Challenge", description: "This is a challenge.", start_date: Date.new(2000,1,1), streak_based: false, rejoinable: false, postfrequency: 0)
    end
  
    #VALID CASE
  
    test "should be valid" do
        assert @challenge.valid?
    end
  
    test "proper end date set" do
        @challenge.end_date = Date.new(2000,2,1)
        assert @challenge.valid?
    end
  
    #INVALID INPUTS
    #name
  
    test "name should be present" do
        @challenge.name = "    "
        assert_not @challenge.valid?
    end
  
    test "name should not be too long" do
        @challenge.name = "a" * 51
        assert_not @challenge.valid?
    end
  
    test "name should not contain excess whitespace" do
        @challenge.name = "Example  User"
        assert_not @challenge.valid?
    end
  
    test "name should not contain preceding whitespace" do
        @challenge.name = " Example User"
        assert_not @challenge.valid?
    end
  
    test "name should not contain appended whitespace" do
        @challenge.name = "Example User "
        assert_not @challenge.valid?
    end
  
    #description

    test "description should be present" do
        @challenge.name = "    "
        assert_not @challenge.valid?
    end
  
    test "description should not be too long" do
        @challenge.name = "a" * 10001
        assert_not @challenge.valid?
    end
  
    #start_date
    
    test "start_date should be present" do
        @challenge.start_date = nil
        assert_not @challenge.valid?
    end
    
    #end_date
    
    test "end_date should not precede start_date" do
        @challenge.end_date = Date.new(1999,1,1)
        assert_not @challenge.valid?
    end
    
    #postfrequency
    
    test "postfrequency should be present" do
        @challenge.postfrequency = nil
        assert_not @challenge.valid?
    end
    
    test "postfrequency should be an integer" do
        @challenge.postfrequency = 3.2
        assert_not @challenge.valid?
    end
    
    test "postfrequency should not be less than -1" do
        @challenge.postfrequency = -2
        assert_not @challenge.valid?
    end
    
    test "postfrequency should not be greater than 7" do
        @challenge.postfrequency = 10
        assert_not @challenge.valid?
    end
    
    #UNIQUENESS
    
    test "names should be unique" do 
        duplicate_challenge = @challenge.dup
        duplicate_challenge.name = @challenge.name.upcase
        @challenge.save
        assert_not duplicate_challenge.valid?
    end
  
end
