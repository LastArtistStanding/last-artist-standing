# frozen_string_literal: true

RSpec.describe House, type: :model do
  houses = []
  house_participants = []
  before do
    (0..2).each do |_i|
      houses.push(create(:house))
    end
    (0..7).each do |_i|
      house_participants.push(create(:house_participation, house_id: houses[0].id, score: 1))
    end
    (8..10).each do |_i|
      house_participants.push(create(:house_participation, house_id: houses[1].id, score: 2))
    end
    (11..11).each do |_i|
      house_participants.push(create(:house_participation, house_id: houses[2].id, score: 6))
    end
  end

  after do
    houses.each(&:delete)
    houses = []
    house_participants.each(&:delete)
    house_participants = []
  end

  describe ':participants' do
    it 'lists all participants in a house' do
      expect(houses[0].users.length).to eq(8)
    end
  end

  describe ':total_score' do
    it 'gives the total score of the house' do
      expect(houses[0].total).to eq(8)
    end
  end

  describe ':place' do
    it 'states the place of each house' do
      expect(houses[0].place).to eq('1st')
    end
  end

  describe ':is_unbalanced?' do
    it 'returns true if a house has 5 more users than any other house' do
      expect(houses[0].unbalanced?).to eq(true)
    end
  end

  describe ':is_old_house?' do
    it 'returns true if a house is older than a month' do
      expect(houses[0].old_house?).to eq(false)
    end
  end
end
