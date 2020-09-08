# frozen_string_literal: true

RSpec.describe House, type: :model do

  houses = []
  house_participants = []

  before(:each) do
    # Set up 3 houses
    (0..2).each do |i|
      houses.push(create(:house))
    end

    # add 8 to the first house
    (0..7).each do |i|
      house_participants.push(create(:house_participation, house_id: houses[0].id, join_date: houses[0].house_start, score: 1))
    end

    # add 3 to the second
    (8..10).each do |i|
      house_participants.push(create(:house_participation, house_id: houses[1].id, join_date: houses[1].house_start, score: 2))
    end

    # add 1 to the third
    (11..11).each do |i|
      house_participants.push(create(:house_participation, house_id: houses[2].id, join_date: houses[2].house_start, score: 6))
    end
  end

  after(:each) do
    houses.each do |h|
      h.delete
    end
    houses = []
    house_participants.each do |hp|
      hp.delete
    end
    house_participants = []
  end

  describe ":participants" do
    it "lists all participants in a house" do
      expect(houses[0].participants.length).to eq(8)
      expect(houses[1].participants.length).to eq(3)
      expect(houses[2].participants.length).to eq(1)
    end
  end

  describe ":total_score" do
    it "gives the total score of the house" do
      expect(houses[0].total_score).to eq(8)
      expect(houses[1].total_score).to eq(6)
      expect(houses[2].total_score).to eq(6)
    end
  end

  describe ":place" do
    it "states the place of each house" do
      expect(houses[0].place).to eq("first")
      expect(houses[1].place).to eq("second") # 2nd and 3rd houses are tied for second
      expect(houses[2].place).to eq("second")
    end
  end

  describe ":is_unbalanced?" do
    it "returns true if a house has 5 more users than any other house" do
      expect(houses[0].is_unbalanced?).to eq(true)
      expect(houses[1].is_unbalanced?).to eq(false)
      expect(houses[2].is_unbalanced?).to eq(false)
    end
  end

  describe ":is_old_house?" do
    it "returns true if a house is older than a month" do
      expect(houses[0].is_old_house?).to eq(false)
      expect(houses[1].is_old_house?).to eq(false)
      expect(houses[2].is_old_house?).to eq(false)

      h = build(:house, house_start: "1970-01-01").is_old_house?
      expect(h).to eq(true)
    end
  end
end
