require 'test_helper'

class BadgeMapTest < ActiveSupport::TestCase

    def setup
        @badge_map = BadgeMap.new(badge_id: 1, challenge_id: 1, required_score: 1, prestige: 1, description: "This is a level 1 badge.")
    end

    #VALID CASE

    test "should be valid" do
        assert @badge_map.valid?
    end

    #INVALID INPUTS
    #badge_id

    test "badge_id should be present" do
        @badge_map.badge_id = nil
        assert_not @badge_map.valid?
    end

    #challenge_id

    test "challenge_id should be present" do
        @badge_map.challenge_id = nil
        assert_not @badge_map.valid?
    end

    #required_score

    test "required_score should be present" do
        @badge_map.required_score = nil
        assert_not @badge_map.valid?
    end

    test "required_score should not be negative" do
        @badge_map.required_score = -4
        assert_not @badge_map.valid?
    end

    test "required_score should not be 0" do
        @badge_map.required_score = 0
        assert_not @badge_map.valid?
    end

    test "required_score should not be a decimal" do
        @badge_map.required_score = 3.2
        assert_not @badge_map.valid?
    end

    #prestige

    test "prestige should be present" do
        @badge_map.prestige = nil
        assert_not @badge_map.valid?
    end

    test "prestige should not be a decimal" do
        @badge_map.prestige = 3.2
        assert_not @badge_map.valid?
    end

    #description

    test "description should be present" do
        @badge_map.description = "  "
        assert_not @badge_map.valid?
    end

    #UNIQUENESS

    test "badge_id, challenge_id and prestige combination should be unique" do
        duplicate_badge_map = @badge_map.dup
        duplicate_badge_map.required_score = @badge_map.required_score + 1
        duplicate_badge_map.description = @badge_map.description + "a"
        @badge_map.save
        assert_not duplicate_badge_map.valid?
    end

end
