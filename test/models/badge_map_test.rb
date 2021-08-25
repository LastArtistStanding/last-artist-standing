# frozen_string_literal: true

require 'test_helper'

class BadgeMapTest < ActiveSupport::TestCase
  def setup
    # The test challenge `id` must be set to a high value if the test
    # environment contains the default challenges created by the various rake `dad_tasks`.
    # Running at least some of the `dad_tasks` is necessary because some of the backend code
    # requires the generated content (at least the patch notes) to be present.
    # It may not be necessary to generate the seasonal and daily challenge, which would make
    # the test valid with an id of `1`, but I think it may be valuable to have the test
    # environment be closer to the production environment anyway.
    @badge_map = BadgeMap.new(badge_id: 100, challenge_id: 100, required_score: 1, prestige: 1,
                              description: 'This is a level 1 badge.')
  end

  # VALID CASE

  test 'should be valid' do
    assert @badge_map.valid?
  end

  # INVALID INPUTS
  # badge_id

  test 'badge_id should be present' do
    @badge_map.badge_id = nil
    assert_not @badge_map.valid?
  end

  # challenge_id

  test 'challenge_id should be present' do
    @badge_map.challenge_id = nil
    assert_not @badge_map.valid?
  end

  # required_score

  test 'required_score should be present' do
    @badge_map.required_score = nil
    assert_not @badge_map.valid?
  end

  test 'required_score should not be negative' do
    @badge_map.required_score = -4
    assert_not @badge_map.valid?
  end

  test 'required_score should not be 0' do
    @badge_map.required_score = 0
    assert_not @badge_map.valid?
  end

  test 'required_score should not be a decimal' do
    @badge_map.required_score = 3.2
    assert_not @badge_map.valid?
  end

  # prestige

  test 'prestige should be present' do
    @badge_map.prestige = nil
    assert_not @badge_map.valid?
  end

  test 'prestige should not be a decimal' do
    @badge_map.prestige = 3.2
    assert_not @badge_map.valid?
  end

  # description

  test 'description should be present' do
    @badge_map.description = '  '
    assert_not @badge_map.valid?
  end

  # UNIQUENESS

  test 'badge_id, challenge_id and prestige combination should be unique' do
    duplicate_badge_map = @badge_map.dup
    duplicate_badge_map.required_score = @badge_map.required_score + 1
    duplicate_badge_map.description = @badge_map.description + 'a'
    @badge_map.save
    assert_not duplicate_badge_map.valid?
  end
end
