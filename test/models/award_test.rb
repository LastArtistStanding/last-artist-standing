require 'test_helper'
require 'date'

class AwardTest < ActiveSupport::TestCase

    def setup
        @award = Award.new(badge_id: 1, user_id: 1, prestige: 1, date_received: Date.new(2000,1,1))
    end

    #VALID CASE

    test "should be valid" do
        assert @award.valid?
    end

    #INVALID INPUTS
    #user_id

    test "user_id should be present" do
        @award.user_id = nil
        assert_not @award.valid?
    end

    #badge_id

    test "badge_id should be present" do
        @award.badge_id = nil
        assert_not @award.valid?
    end

    #prestige

    test "prestige should be present" do
        @award.prestige = nil
        assert_not @award.valid?
    end

    test "prestige should not be a decimal" do
        @award.prestige = 3.2
        assert_not @award.valid?
    end

    #date_received

    test "date_received should be present" do
        @award.date_received = nil
        assert_not @award.valid?
    end

    #UNIQUENESS

    test "user_id and badge_id combination should be unique" do
        duplicate_award = @award.dup
        duplicate_award.prestige = @award.prestige + 1
        duplicate_award.prestige = @award.date_received + 1
        @award.save
        assert_not duplicate_award.valid?
    end

end
