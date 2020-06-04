# frozen_string_literal: true

class BadgeTest < ActiveSupport::TestCase
  def setup
    @badge = build(:badge)
  end

  test 'should be valid' do
    assert @badge.valid?
  end

  test 'name should be present' do
    @badge.name = '    '
    assert_not @badge.valid?
  end

  test 'name should not be too long' do
    @badge.name = 'a' * 101
    assert_not @badge.valid?
  end

  test 'name should not contain excess whitespace' do
    @badge.name = 'Badge  Name'
    assert_not @badge.valid?
  end

  test 'name should not contain preceding whitespace' do
    @badge.name = ' Badge Name'
    assert_not @badge.valid?
  end

  test 'name should not contain appended whitespace' do
    @badge.name = 'Badge Name '
    assert_not @badge.valid?
  end

  test 'avatar should be present' do
    @badge.avatar = '    '
    assert_not @badge.valid?
  end

  test 'names should be unique' do
    file2 = Rack::Test::UploadedFile.new(Rails.root.join('app/assets/images/lastan_2.png'), 'image/png')
    duplicate_badge = build(:badge, name: 'CHALLENGE BADGE', avatar: file2)
    @badge.save
    assert_not duplicate_badge.valid?
  end
end
