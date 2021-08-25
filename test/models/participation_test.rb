# frozen_string_literal: true

require 'test_helper'
require 'date'

class ParticipationTest < ActiveSupport::TestCase
  def setup
    @participation = Participation.new(user_id: 1, challenge_id: 1, score: 1,
                                       start_date: Date.new(2000, 1, 1))
  end

  # VALID CASE

  test 'should be valid' do
    assert @participation.valid?
  end

  # INVALID INPUTS
  # user_id

  test 'user_id should be present' do
    @participation.user_id = nil
    assert_not @participation.valid?
  end

  # challenge_id

  test 'challenge_id should be present' do
    @participation.challenge_id = nil
    assert_not @participation.valid?
  end

  # score

  test 'score should be present' do
    @participation.score = nil
    assert_not @participation.valid?
  end

  test 'score should not be a decimal' do
    @participation.score = 3.2
    assert_not @participation.valid?
  end

  test 'score should not be negative' do
    @participation.score = -3
    assert_not @participation.valid?
  end

  # start_date

  test 'start_date should not be negative' do
    @participation.start_date = nil
    assert_not @participation.valid?
  end

  # end_date

  test 'end_date should not precede start_date' do
    @participation.end_date = Date.new(1999, 1, 1)
    assert_not @participation.valid?
  end

  # UNIQUENESS
end
