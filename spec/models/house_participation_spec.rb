# frozen_string_literal: true

describe HouseParticipation do
  it 'adds points to a users participation record' do
    hp = build(:house_participation)
    hp.add_points(1)
    expect(hp.score).to eq(1)
  end

  it 'removes points from a users participation record' do
    hp = build(:house_participation)
    hp.add_points(1)
    hp.remove_points(1)
    expect(hp.score).to eq(0)
  end

  it 'updates points from a users participation record' do
    hp = build(:house_participation)
    hp.add_points(2)
    hp.update_points(2, 3, Time.now.utc)
  end

  it 'does not update points from old records' do
    hp = build(:house_participation)
    hp.add_points(2)
    hp.update_points(2, 3, Time.now.utc.prev_month)
    expect(hp.score).to eq(2)
  end
end
