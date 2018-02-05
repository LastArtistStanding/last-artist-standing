require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  
    def setup 
        @badge = Badge.new(name: "Badge Name", avatar: "imagelink")
    end
  
    #VALID CASE
  
    test "should be valid" do
        assert @badge.valid?
    end
  
    #INVALID INPUTS
    #name
  
    test "name should be present" do
        @badge.name = "    "
        assert_not @badge.valid?
    end
  
    test "name should not be too long" do
        @badge.name = "a" * 51
        assert_not @badge.valid?
    end
  
    test "name should not contain excess whitespace" do
        @badge.name = "Badge  Name"
        assert_not @badge.valid?
    end
  
    test "name should not contain preceding whitespace" do
        @badge.name = " Badge Name"
        assert_not @badge.valid?
    end
  
    test "name should not contain appended whitespace" do
        @badge.name = "Badge Name "
        assert_not @badge.valid?
    end
  
    #avatar
  
    test "avatar should be present" do
        @badge.avatar = "    " 
        assert_not @badge.valid?
    end
  
    #UNIQUENESS
  
    test "names should be unique" do 
        duplicate_badge = @badge.dup
        duplicate_badge.name = @badge.name.upcase
        duplicate_badge.avatar = "a" + @badge.avatar
        @badge.save
        assert_not duplicate_badge.valid?
    end
  
end
