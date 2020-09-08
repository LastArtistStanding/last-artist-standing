# frozen_string_literal: true

describe HouseParticipation do

  describe ":add_points" do
    it "adds points to a users participation record" do
      hp = build(:house_participation)
      expect(hp.score).to eq(0)
      hp.add_points(1)
      expect(hp.score).to eq(1)
    end
  end

  describe ":remove_points" do
    it "removes points from a users participation record" do
      hp = build(:house_participation)
      expect(hp.score).to eq(0)
      hp.add_points(1)
      expect(hp.score).to eq(1)
      hp.remove_points(1)
      expect(hp.score).to eq(0)
    end
  end

  describe ":update_points" do
    it "updates points from a users participation record" do
      hp = build(:house_participation)
      expect(hp.score).to eq(0)
      hp.add_points(2)
      expect(hp.score).to eq(2)
      hp.update_points(2, 3, Time.now.utc.month)
      expect(hp.score).to eq(3)
    end

    it "does not update points from old records" do
      hp = build(:house_participation)
      expect(hp.score).to eq(0)
      hp.add_points(2)
      expect(hp.score).to eq(2)
      hp.update_points(2, 3, Time.now.utc.prev_month.month)
      expect(hp.score).to eq(2)
    end
  end


end
