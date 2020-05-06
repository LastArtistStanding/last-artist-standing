require 'test_helper'

class ChallengeEntryTest < ActiveSupport::TestCase

    def setup
        @challenge_entry = ChallengeEntry.new(challenge_id: 1, submission_id: 1)
    end

    #VALID CASE

    test "should be valid" do
        assert @challenge_entry.valid?
    end

    #INVALID INPUTS
    #challenge_id

    test "challenge_id should be present" do
        @challenge_entry.challenge_id = nil
        assert_not @challenge_entry.valid?
    end

    #submission_id

    test "submission_id should be present" do
        @challenge_entry.submission_id = nil
        assert_not @challenge_entry.valid?
    end

    #UNIQUENESS

    test "challenge_id and submission_id combination should be unique" do
        duplicate_challenge_entry = @challenge_entry.dup
        @challenge_entry.save
        assert_not duplicate_challenge_entry.valid?
    end

end
